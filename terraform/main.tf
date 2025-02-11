
##############################
# VPC and Networking
###############################

module "vpc" {
  source = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/vpc?ref=FEAT-3"
  # Module variables
  name        = var.name
  cidr_block  = "10.0.0.0/16"
  subnet_bits = 8
}

###############################
# Security Groups
###############################
module "security_groups" {
  source = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/security-group?ref=FEAT-3"
  name   = var.name
  vpc_id = module.vpc.vpc_id
}


###############################
# Application Load Balancer
###############################
module "alb" {
  source         = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/alb?ref=FEAT-3"
  name           = var.name
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.security_groups.alb_sg_id
  target_port    = 80
}


###############################
# ECS Cluster
###############################
module "ecs_cluster" {
  source = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/cluster?ref=FEAT-3"
  name   = var.name
}


###############################
# EC2 Auto Scaling Groups for ECS Tasks
###############################
module "ec2_asg" {
  source           = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/ec2-asg?ref=FEAT-3"
  name             = var.name
  instance_type    = "m7a.xlarge"
  key_name         = var.name
  ecs_cluster_name = module.ecs_cluster.ecs_cluster_id
  private_subnets  = module.vpc.private_subnets
  ecs_sg_id        = module.security_groups.ecs_sg_id
  ondemand_min     = 0
  ondemand_max     = 4
  ondemand_desired = 1
  spot_min         = 0
  spot_max         = 4
  spot_desired     = 1
}


###############################
# ECS Capacity Providers
###############################
module "capacity_providers" {
  source           = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/capacity-providers?ref=FEAT-3"
  ondemand_asg_arn = module.ec2_asg.ondemand_asg_arn
  spot_asg_arn     = module.ec2_asg.spot_asg_arn
}


###############################
# ECS Task Execution IAM Role
###############################
module "iam" {
  source = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/iam?ref=FEAT-3"
  name   = var.name
}

###############################
# ECS Task Definitions
###############################
module "ecs_task_ec2" {
  source             = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/ec2-task-definition?ref=FEAT-3"
  family             = "${var.name}-ec2"
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  image              = "nginxdemos/hello"
  container_port     = 80
}

module "ecs_task_fargate" {
  source             = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/fargate-task-definition?ref=FEAT-3"
  family             = "${var.name}-fargate"
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  image              = "nginxdemos/hello"
  container_port     = 80
}


###############################
# ECS Services
###############################
module "ecs_service_ec2" {
  source              = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/ec2-service?ref=FEAT-3"
  name                = "${var.name}-service-ec2"
  cluster_id          = module.ecs_cluster.ecs_cluster_id
  task_definition_arn = module.ecs_task_ec2.ecs_task_definition_arn
  spot_cp_name        = module.capacity_providers.spot_cp_name
  ondemand_cp_name    = module.capacity_providers.ondemand_cp_name
  spot_weight         = 90
  ondemand_weight     = 10
  desired_count       = 5
  target_group_arn    = module.alb.ec2_target_group_arn
  container_name      = "web"
  container_port      = 80
}

module "ecs_service_fargate" {
  source                   = "git::https://github.com/proxyserver2023/alexandria.git//modules/aws/ecs/fargate-service?ref=FEAT-3"
  name                     = "${var.name}-service-fargate"
  cluster_id               = module.ecs_cluster.ecs_cluster_id
  task_definition_arn      = module.ecs_task_fargate.ecs_task_definition_arn
  fargate_spot_weight      = 90
  fargate_on_demand_weight = 10
  desired_count            = 10
  subnets                  = module.vpc.private_subnets
  security_groups          = [module.security_groups.ecs_sg_id]
  target_group_arn         = module.alb.fargate_target_group_arn
  container_name           = "web"
  container_port           = 80
}
