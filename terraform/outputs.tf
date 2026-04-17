output "alb_dns_name" {
  description = "DNS name of the public application load balancer."
  value       = aws_lb.app.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "secret_arn" {
  description = "ARN of the example application secret."
  value       = aws_secretsmanager_secret.app.arn
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by the ECS service."
  value       = [for subnet in aws_subnet.private : subnet.id]
}
