locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env  = local.environment_vars.locals.environment
  name = "ec2-server-${local.env}"
}

terraform {
  source = "git@github.com:techservicesillinois/terraform-aws-eip.git?ref=v3.0.0"
    }

include {
  path = find_in_parent_folders()
}

dependency "ec2" {
    config_path  = "../ec2"
    mock_outputs = {
      id = "ec2-id-mock"
  }
}

dependency "vpc" {
    config_path  = "../vpc"
    mock_outputs = {
      private_subnets = ["private-subnet-id-az1", "private-subnet-id-az1"]
    }
}


inputs = {

    name        = local.name
    vpc_id      = dependency.vpc.outputs.vpc_id

    instance = dependency.ec2.outputs.id

    tags = {
        Terraform = "true"
        Environment = "${local.env}"
        Region = local.environment_vars.locals.aws_region
    }
}