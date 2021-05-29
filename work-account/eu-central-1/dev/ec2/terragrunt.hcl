terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git?ref=v2.19.0"
    }

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
    config_path  = "../vpc"
    mock_outputs = {
      private_subnets = ["private-subnet-id-az1", "private-subnet-id-az1"]
    }
}

dependency "ssh" {
    config_path  = "../security/http-security-group"
    mock_outputs = {
      security_group_id = "security-group-mock"
    }
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env  = local.environment_vars.locals.environment
  name = "ec2-server-${local.env}"
}

inputs = {
    name                   = local.name
    instance_count         = local.environment_vars.locals.instance_default_number

    ami                    = local.environment_vars.locals.instance_default_ami
    instance_type          = local.environment_vars.locals.instance_default_type
    key_name               = local.environment_vars.locals.instance_default_key_name
    monitoring             = false
    vpc_security_group_ids = [dependency.ssh.outputs.security_group_id]
    subnet_ids             = dependency.vpc.outputs.private_subnets

    tags = {
        Terraform = "true"
        Environment = "${local.env}"
        Region = local.environment_vars.locals.aws_region
    }
}