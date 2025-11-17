output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "ecs_cluster" {
  value = aws_ecs_cluster.cluster.name
}

output "ecs_service" {
  value = aws_ecs_service.service.name
}

output "task_definition" {
  value = aws_ecs_task_definition.task.arn
}
