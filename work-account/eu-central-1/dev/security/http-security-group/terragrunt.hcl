locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env  = local.environment_vars.locals.environment
  name = "ec2-server-${local.env}"
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-security-group.git?ref=v4.2.0"
    }

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
    config_path  = "../../vpc"
    mock_outputs = {
      vpc_id = "vpc-id-mock"
  }
}

inputs = {

    name        = local.name
    description = "Security group with custom ports open within VPC http publicly open"
    vpc_id      = dependency.vpc.outputs.vpc_id

    ingress_cidr_blocks      = local.environment_vars.locals.ingress_all_cidr_blocks
    ingress_rules            = ["http-80-tcp"]

    tags = {
        Terraform = "true"
        Environment = "${local.env}"
        Region = local.environment_vars.locals.aws_region
    }
}