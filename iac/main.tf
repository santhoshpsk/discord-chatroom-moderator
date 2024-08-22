terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-santhosh30"
    region         = "ap-south-1"
    key            = "discord-chatroom-moderator/iac/terraform.tfstate"
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

resource "aws_ssm_parameter" "discord-bot-secret-token" {
  name = "/discord/bot/secret-token"
  type = "SecureString"
  value = "place holder"
}

resource "aws_iam_role" "ecs-task-role" {
  name_prefix = "${var.project-name}-"
  path        = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },

    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  /*
  inline_policy {
    name = "k8s-worker-node-inline-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:SendCommand",
            "ssm:ListCommandInvocations",
            "ssm:GetCommandInvocation"
          ]
          Effect   = "Allow"
          Resource = ["*"]
        },

      ]
    })
  }
  */
}

output "ecs-task-role-arn" {
  description = "Role ARN of the ECS Task"
  value = aws_iam_role.ecs-task-role.arn
}

output "ecs-cluster-arn" {
  description = "ECS Cluster ARN to run the ECS Task"
  value = aws_ecs_cluster.main-ecs-cluster.arn
}

output "ecr-repo-url" {
  description = "ECS Cluster ARN to run the ECS Task"
  value = aws_ecr_repository.main-ecr-repo.url
}