provider "aws" {
  region = var.region

  default_tags {
    tags = {
      hashicorp-learn = "move-config"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway      = var.vpc_enable_nat_gateway
  map_public_ip_on_launch = true

  tags = var.vpc_tags
}

module "ec2_instance" {
  source          = "./modules/compute"
  security_group = module.security_group.sg_id
  public_subnets  = module.learn_vpc.public_subnets
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id    = module.learn_vpc.vpc_id
}

moved {
  from = aws_instance.example
  to = module.ec2_instance.aws_instance.example
}

moved {
  from = aws_security_group.sg_8080
  to = module.security_group.aws_security_group.sg
}

moved {
  from = module.vpc
  to   = module.learn_vpc
}