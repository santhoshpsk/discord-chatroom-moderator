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
      image = ""
      cpu = 256
      memory = 512
      requires_compatibilities = "FARGATE"
      task_role_arn = aws_iam_role.ecs-task-role.arn
      track_latest = true
    }
  ])
}