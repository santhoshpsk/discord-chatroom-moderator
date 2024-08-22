terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-santhosh30"
    region         = "ap-south-1"
    key            = "discord-chatroom-moderator/deployment/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_ecs_task_definition" "ecs-main-task-definition" {
  family = "chatroom-moderator-service"
  container_definitions = jsonencode([
    {
      name = "main-container"
      essential = true
      image = "${var.ecr-repo-url}:${var.ecs-task-image-tag}"
      cpu = 256
      memory = 512    
    }
  ])
  track_latest = true
  requires_compatibilities = ["FARGATE"]
  task_role_arn = var.ecs-task-role-arn
}

resource "aws_ecs_service" "ecs-main-task-service" {
  name = "chatroom-moderator-service"
  cluster = var.ecs-cluster-arn
  task_definition = aws_ecs_task_definition.ecs-main-task-definition.arn
  desired_count = 1
}