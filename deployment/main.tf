terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-santhosh"
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
      name = "main-service"
      essential = true
      image = "${var.ecr-repo-name}:${var.ecs-task-image-tag}"
      cpu = 256
      memory = 512
      requires_compatibilities = "FARGATE"
      task_role_arn = var.ecs-task-role-arn
      track_latest = true
    }
  ])
}

resource "aws_ecs_service" "ecs-main-task-service" {
  name = "main-service"
  cluster = var.ecs-cluster-arn
  task_definition = aws_ecs_task_definition.ecs-main-task-definition.arn
}