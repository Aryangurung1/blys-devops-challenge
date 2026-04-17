variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project prefix used in resource names."
  type        = string
  default     = "blys-poc"
}

variable "environment" {
  description = "Environment name used for tagging and naming."
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "availability_zones" {
  description = "Optional override for the two AZs used by the stack."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Two CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.42.0.0/24", "10.42.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Two CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.42.10.0/24", "10.42.11.0/24"]
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed to reach the ALB over HTTP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "container_image" {
  description = "Container image for the hello-world service."
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable-alpine"
}

variable "container_port" {
  description = "Port exposed by the container."
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum task count for ECS service autoscaling."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum task count for ECS service autoscaling."
  type        = number
  default     = 4
}

variable "nat_gateway_mode" {
  description = "NAT strategy: single keeps costs lower, one_per_az maximizes AZ-level resilience."
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "one_per_az"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be either 'single' or 'one_per_az'."
  }
}

variable "secret_value" {
  description = "Sample application secret stored in Secrets Manager."
  type        = string
  sensitive   = true
  default     = "devops"
}
