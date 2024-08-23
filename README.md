# Discord Chatroom Moderator

This project is a Discord chatroom moderator bot designed to automatically analyze images posted in a Discord server and remove those containing disallowed content such as Smoking, Explicit, Gambling, and Violence. The bot also tags the post author with a message indicating the reason for the removal.

![Removing disallowed content from your discord](<assets/discord-chatroom-moderator-usage.gif>)

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Infrastructure as Code (IaC)](#infrastructure-as-code-iac)
- [Application Deployment](#application-deployment)
- [Source Code](#source-code)
- [Usage](#usage)
- [Future Enhancements](#future-enhancements)
- [License](#license)

## Project Overview

The Discord Chatroom Moderator is implemented in Python and leverages AWS Rekognition to analyze images. Images that exceed AWS Rekognition's 5MB input size limit are automatically resized. The bot is deployed using Terraform, and the CI/CD pipeline is managed with Azure DevOps. The application runs on AWS ECS with minimal resources.

## Features

- **Automated Image Moderation:** Analyzes images in Discord posts to detect and remove disallowed content.
- **Content Categories:** Filters images based on the following categories:
  - Smoking
  - Explicit content
  - Gambling
  - Violence
- **Image Resizing:** Automatically resizes images larger than 5MB to comply with AWS Rekognition's limitations.
- **Tagging Authors:** Tags the author of the post when their image is removed, explaining the reason.

## Prerequisites

Before deploying this project, ensure you have the following:

- **Terraform:** Installed and configured on your machine.
- **AWS Account:** With necessary permissions to use AWS Rekognition.
- **Azure DevOps:** For managing the CI/CD pipeline.
- **Docker:** For building and running the application.

## Directory Structure

The project is organized into three main directories:

```
discord-chatroom-moderator/
│
├── deployment
│   ├── azure-pipeline.yml
│   ├── main.tf
│   ├── terraform.tfvars
│   └── variables.tf
├── iac
│   ├── azure-pipeline.yml
│   ├── main.tf
│   ├── terraform.tfvars
│   └── variables.tf
└── src
    ├── Dockerfile
    ├── main.py
    └── requirement.pip
```

- **iac/**: Contains Terraform code for deploying the infrastructure.
- **deployment/**: Contains Terraform code and Azure DevOps pipeline configuration for application deployment.
- **src/**: Contains the source code for the Discord bot and the Dockerfile for containerization.

## Infrastructure as Code (IaC)

The `iac/` directory contains all the Terraform code needed to deploy the AWS infrastructure required for this project. This includes the necessary AWS services such as Rekognition and any other resources needed for the bot to function.

### Remote Backend Setup

This project uses an S3 bucket and a DynamoDB table as the Terraform remote backend. Before running the Terraform commands, you'll need to set up your own S3 bucket and DynamoDB table.

1. **Create an S3 Bucket:**
   - The S3 bucket will be used to store the Terraform state files.
   - Ensure the bucket name is unique globally.

2. **Create a DynamoDB Table:**
   - The DynamoDB table is used for state locking and consistency.
   - Use `LockID` as the primary key for the table.

3. **Update the `backend` block in `iac/main.tf`:**
   - In the `iac/main.tf` file, update the `bucket` and `dynamodb_table` values in the `backend` block with your S3 bucket name and DynamoDB table name.

```hcl
terraform {
  backend "s3" {
    bucket         = "your-s3-bucket-name"
    key            = "path/to/your/terraform.tfstate"
    region         = "your-aws-region"
    dynamodb_table = "your-dynamodb-table-name"
  }
}
```

### Deploying the Infrastructure

After setting up the remote backend, navigate to the `iac/` directory and run the following commands:

```sh
terraform init
terraform plan
terraform apply
```

This will deploy all necessary infrastructure components to AWS.

## Application Deployment

The `deployment/` directory contains the Terraform code and Azure DevOps pipeline configuration for deploying the Discord bot application itself. The application runs on AWS ECS with minimal resource allocation: 0.25 vCPU and 512 MB RAM.

### Steps to Deploy

1. **Set Up Remote Backend:**
   - Like the IaC, the deployment Terraform code also uses S3 and DynamoDB as a remote backend.
   - Update the `backend` block in `deployment/main.tf` with your S3 bucket and DynamoDB table details.

```hcl
terraform {
  backend "s3" {
    bucket         = "your-s3-bucket-name"
    key            = "path/to/your/deployment-terraform.tfstate"
    region         = "your-aws-region"
    dynamodb_table = "your-dynamodb-table-name"
  }
}
```

2. **Customize the Azure Pipeline:**
   - Modify the `azure-pipelines.yml` file in the `deployment/` directory as needed.

3. **Trigger Deployment:**
   - Trigger the pipeline in Azure DevOps to deploy the bot application to AWS ECS.

![CI/CD](<assets/ci-cd.gif>)

## Source Code

The `src/` directory contains the source code for the Discord bot:

- **bot.py:** The main script that handles image moderation.
- **Dockerfile:** Used to build a Docker image of the bot.
- **requirements.txt:** Lists the Python dependencies for the project.

To build and run the bot locally, navigate to the `src/` directory and run:

```sh
docker build -t discord-moderator .
docker run discord-moderator
```

## Usage

Once deployed, the bot will automatically monitor images posted in the Discord server. When it detects disallowed content, it will remove the image and notify the author.

### Example

If a user posts an image containing violent content, the bot will delete the image and post a message tagging the user:

```
@username, Your image was removed as posting Violence content is disallowed in this channel
```

![Removing disallowed content from your discord](<assets/discord-chatroom-moderator-usage.gif>)