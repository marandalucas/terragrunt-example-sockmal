locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
  name = "vpc-${local.env}"
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git?ref=v3.0.0"
    }

include {
  path = find_in_parent_folders()
}

inputs = {
  name = local.name
  cidr = local.environment_vars.locals.vpc_cidr

  azs             = local.environment_vars.locals.vpc_azs
  private_subnets = local.environment_vars.locals.vpc_private_subnets
  public_subnets  = local.environment_vars.locals.vpc_public_subnets

  // Single NAT Gateway
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform = "true"
    Environment = "${local.env}"
    Region = local.environment_vars.locals.aws_region
  }
}