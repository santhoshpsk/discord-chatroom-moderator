variable "region" {
  type = string
  description = "AWS Region"
}

variable "project-name" {
  type = string
  description = "Name of this project"
}

variable "ecr-repo-name" {
  type = string
  description = "ECR Repository name"
}

variable "ecs-task-image-tag" {
  type = string
  description = "Docker image tag for ECS task main container"
}

variable "ecs-cluster-arn" {
  type = string
  description = "ECS Cluster ARN"
}

variable "ecs-task-role-arn" {
  type = string
  description = "ECS Task Role ARN"
}