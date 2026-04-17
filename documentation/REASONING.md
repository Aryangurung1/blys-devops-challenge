# Strategy and Reasoning

## Overview

This file explains why I made the main architecture choices for this task.

My goal was not only to make the AWS setup work, but to make choices that are:

- secure
- easy to explain
- cost-aware
- simple to operate

The solution uses:

- Terraform
- VPC with public and private subnets
- ECS Fargate
- Application Load Balancer
- Secrets Manager
- CloudWatch

## 1. Cost Reduction

### NAT Gateway choice

One of the biggest cost decisions in this setup is the NAT Gateway design.

The Terraform supports two options:

- `single`
  one NAT Gateway for the whole VPC
- `one_per_az`
  one NAT Gateway in each Availability Zone

For this task, I used `single` as the default.

I did this because it gives a better balance between cost and reliability for a working demo.

With one NAT Gateway:

- the app is still spread across 2 Availability Zones
- the ALB is still spread across 2 Availability Zones
- ECS tasks can still run in private subnets
- but the AWS bill stays lower

If I used one NAT Gateway per AZ, the setup would be more resilient for outbound traffic, but it would also cost more.

So this was a deliberate tradeoff:

- keep the application tier multi-AZ
- keep the public entrypoint multi-AZ
- reduce network cost where possible

### VPC Endpoints

Yes, VPC endpoints are a good way to reduce NAT Gateway usage and cost, and they are worth mentioning.

In a more complete version of this setup, I would add VPC endpoints for AWS services that the private application needs often, such as:

- ECR API
- ECR DKR
- CloudWatch Logs
- Secrets Manager

Why this helps:

- private tasks can talk to these AWS services without going through the NAT Gateway
- that reduces NAT data processing cost
- it also improves security because traffic stays inside AWS private networking

So if the service grew, adding VPC endpoints would be one of the first cost improvements I would make.

### Why I used Fargate

I chose ECS Fargate instead of EC2 instances.

Why:

- I do not need to manage servers
- I do not need to patch EC2 instances
- I do not need to manage AMIs
- I do not need to manage an Auto Scaling Group

For a small containerized service, Fargate is a clean choice because it reduces operational work.

So the cost benefit here is not only AWS pricing. It also reduces engineering time and platform management effort.

## 2. Disaster Recovery (DR)

### What the current setup can handle

The current setup is multi-AZ, but it is not multi-region.

That means it can handle:

- one ECS task failing
- one subnet having a problem
- one Availability Zone going down

But it does not automatically handle a full AWS Region outage.

### If a full AWS Region went down

To recover in another region, I would do these steps:

1. change the Terraform region variable
2. apply the Terraform code in the second region
3. make sure the Docker image is available in that region
4. create the secret again in that region
5. point DNS to the new ALB

The main strength here is that the infrastructure is written as code.

That means I do not need to rebuild everything manually during an incident. I can recreate the same environment in another region in a much more controlled way.

## 3. Observability

### What is already implemented

Right now the setup uses CloudWatch.

That includes:

- CloudWatch Logs for container logs
- ECS Container Insights for ECS metrics
- ALB health checks for target health

This is enough for a working demo and gives basic visibility into:

- whether the app is running
- whether tasks are healthy
- whether the load balancer can reach the app
- what the container is logging

### Why I started with CloudWatch

I picked CloudWatch first because this is an AWS-native stack.

It is the simplest and most practical first step because:

- it works directly with ECS
- it works directly with ALB
- it is quick to set up
- it is enough for a small service

### What I would add next

The next observability improvements I would make are:

- CloudWatch alarms for high CPU
- CloudWatch alarms for ALB 5xx errors
- alarms for unhealthy targets
- dashboards for ECS and ALB health

If the system became larger later, then I would consider:

- Prometheus and Grafana for deeper metrics
- ELK or OpenSearch for advanced log analysis

But for this task, I would not start with ELK because it adds too much complexity for a small service.

So my practical observability stack for this challenge would be:

- CloudWatch Logs
- ECS Container Insights
- CloudWatch alarms

## 4. Security Reasoning

The main security decisions are:

- ECS tasks run in private subnets
- the ALB is the only public entry point
- ECS tasks only accept traffic from the ALB
- secrets are stored in Secrets Manager
- IAM permissions are limited to the specific secret
- AWS credentials are not hardcoded in Terraform

This follows least privilege and keeps the app tier private.

If I extended this later, I would add:

- HTTPS with ACM
- image scanning in CI/CD
- GitHub OIDC instead of long-lived AWS access keys
- CloudWatch alarms for faster incident response

These would make the setup stronger for a real production environment.
