# Proxima

This example demonstrates how to deploy a high-throughput ECS (Elastic Container Service) architecture using Terraform. The configuration includes setting up a VPC, security groups, an Application Load Balancer (ALB), ECS clusters, EC2 Auto Scaling Groups, and ECS capacity providers.

## Overview

The example deploys a scalable ECS architecture that can handle high transactions per second (TPS). It leverages both EC2 and Fargate launch types for running ECS tasks, with capacity providers to manage the scaling of EC2 instances.

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- AWS CLI configured with appropriate credentials
- GitHub token for accessing private repositories

### Run

1. Log in to AWS SSO:
   ```sh
   aws sso login --profile <aws_profile>
   ```
2. Set the AWS profile:
   ```sh
   export AWS_PROFILE=<aws_profile>
   ```
3. cd into terraform and run
   ```sh
   terraform init
   terraform plan
   terraform apply
   ```

## Usage

### Modules

The architecture uses various modules to set up the infrastructure:

- **VPC and Networking**: Sets up the VPC and subnets.
- **Security Groups**: Configures security groups for ALB and ECS.
- **Application Load Balancer**: Creates an ALB for routing traffic to ECS tasks.
- **ECS Cluster**: Sets up an ECS cluster.
- **EC2 Auto Scaling Groups**: Configures EC2 instances for running ECS tasks.
- **ECS Capacity Providers**: Manages scaling of EC2 instances.
- **ECS Task Definitions**: Defines ECS tasks for both EC2 and Fargate launch types.
- **ECS Services**: Deploys ECS services using the defined task definitions.

### Example Configuration

The main.tf file contains the example configuration. It demonstrates how to use the modules to set up a high-throughput ECS architecture.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your changes.

## License

This project is licensed under the MIT License.
