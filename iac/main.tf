terraform {
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

resource "aws_ecs_cluster" "main-ecs-cluster" {
  name = "chatroom-moderator-cluster"
  setting {
    name = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecr_repository" "main-ecr-repo" {
  name = "chatroom-moderator-repository"
}