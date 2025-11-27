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
# DATA - AMI do ECS otimizada
##############################################
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

##############################################
# ECS CLUSTER
##############################################
resource "aws_ecs_cluster" "cluster" {
  name = "ecs-nextgenz-cluster"
}

##############################################
# SECURITY GROUPS
##############################################

# ALB
resource "aws_security_group" "alb_sg" {
  name   = "nextgenz-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow HTTP 5000"
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

# ECS INSTANCES
resource "aws_security_group" "ecs_sg" {
  name   = "nextgenz-ecs-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow ALB to reach ECS Tasks"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    security_groups = [
      aws_security_group.alb_sg.id
    ]
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
    name = "LabInstanceProfile"
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ecs_sg.id]
  }

  # CORREÇÃO IMPORTANTE: USER DATA COMPLETO
 user_data = base64encode(<<-EOF
#!/bin/bash
set -xe
echo "ECS_CLUSTER=${aws_ecs_cluster.cluster.name}" > /etc/ecs/ecs.config
sudo yum remove -y ecs-init
sudo yum install -y ecs-init
sudo systemctl enable --now ecs
sudo systemctl restart ecs
EOF
)
}

##############################################
# AUTO SCALING GROUP
##############################################
resource "aws_autoscaling_group" "ecs_asg" {
  name                = "nextgenz-ecs-asg"
  vpc_zone_identifier = var.private_subnets

  min_size         = 1
  max_size         = 2
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nextgenz-ecs-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

##############################################
# ALB + TARGET GROUP (IP MODE)
##############################################
resource "aws_lb" "alb" {
  name               = "nextgenz-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "tg" {
  name        = "nextgenz-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
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
# ECS TASK DEFINITION
##############################################
locals {
  lab_role_arn = "arn:aws:iam::448506098935:role/LabRole"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "nextgenz-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  cpu    = "256"
  memory = "512"

  task_role_arn      = local.lab_role_arn
  execution_role_arn = local.lab_role_arn

  container_definitions = jsonencode([
    {
      name      = "nextgenz-container",
      image     = var.app_image,
      essential = true,
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ],
      environment = [
        { name = "DB_NAME",     value = "nextgenz" },
        { name = "DB_USER",     value = "app_user" },
        { name = "DB_PASSWORD", value = "SenhaForte123!" },
        { name = "DB_HOST",     value = var.db_host }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" : "/ecs/nextgenz",
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "cw" {
  name              = "/ecs/nextgenz"
  retention_in_days = 7
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
    container_name   = "nextgenz-container"
    container_port   = 5000
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
  }

  depends_on = [
    aws_lb_listener.listener
  ]
}

##############################################
# OUTPUTS
##############################################
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "task_definition" {
  value = aws_ecs_task_definition.task.arn
}