terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.region
}

##############################################
# ECS CLUSTER
##############################################
resource "aws_ecs_cluster" "cluster" {
  name = "ecs-nextgenz-cluster"
}

##############################################
# IAM INSTANCE PROFILE (LabRole)
##############################################
data "aws_iam_instance_profile" "labrole" {
  name = "LabInstanceProfile"
}

##############################################
# ECS-OPTIMIZED AMI
##############################################
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

##############################################
# SECURITY GROUPS
##############################################

# SG do ALB
resource "aws_security_group" "alb_sg" {
  name   = "nextgenz-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG da EC2 do ECS
resource "aws_security_group" "ecs_sg" {
  name   = "nextgenz-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################################
# LAUNCH TEMPLATE
##############################################
resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "nextgenz-lt-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type
  key_name      = "vockey"

  iam_instance_profile {
    name = data.aws_iam_instance_profile.labrole.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ecs_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=ecs-nextgenz-cluster" >> /etc/ecs/ecs.config
    systemctl enable --now ecs
  EOF
  )
}

##############################################
# AUTO SCALING GROUP
##############################################
resource "aws_autoscaling_group" "ecs_asg" {
  name                = "nextgenz-ecs-asg"
  vpc_zone_identifier = var.private_subnets

  desired_capacity = 1
  min_size         = 1
  max_size         = 1

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nextgenz-ecs-instance"
    propagate_at_launch = true
  }
}

##############################################
# TARGET GROUP – PORTA 5000
##############################################
resource "aws_lb_target_group" "tg" {
  name        = "nextgenz-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/status"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
    matcher             = "200"
  }
}

##############################################
# LOAD BALANCER – LISTENER 5000
##############################################
resource "aws_lb" "alb" {
  name               = "nextgenz-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

##############################################
# TASK DEFINITION – 100% compatível com app.py
##############################################
resource "aws_ecs_task_definition" "task" {
  family                   = "ecs-nextgenz-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  cpu    = "256"
  memory = "512"

  task_role_arn      = var.lab_role_arn
  execution_role_arn = var.lab_role_arn

  container_definitions = jsonencode([
    {
      name      = "ecs-nextgenz-container"
      image     = var.app_image
      essential = true

      environment = [
        { name = "DB_NAME",     value = "nextgenz" },
        { name = "DB_USER",     value = "app_user" },
        { name = "DB_PASSWORD", value = "SenhaForte123!" },
        { name = "DB_HOST",     value = var.db_host }
      ]

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

##############################################
# ECS SERVICE
##############################################
resource "aws_ecs_service" "service" {
  name            = "nextgenz-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "ecs-nextgenz-container"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener.listener,
    aws_autoscaling_group.ecs_asg
  ]
}
