terraform {
  source = "git@github.com:terraform-aws-modules/aws_db_instance.git?ref=v2.19.0"
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

dependency "instance-security" {
    config_path  = "../security/instance-security-group"
    mock_outputs = {
      security_group_id = "security-group-mock"
    }
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env  = local.environment_vars.locals.environment
  name = "postgres-rds-${local.env}"
}

inputs = {
    engine         = "postgres"
    engine_version = "13.3"

    name     = var.name
    username = local.environment_vars.locals.user_db
    password = local.environment_vars.locals.user_pass

    instance_class    = local.environment_vars.locals.ins_class
    allocated_storage = local.environment_vars.locals.alloc_torage
    storage_type      = local.environment_vars.locals.storge_type
    security_group_id = local.environment_vars.locals.instance_default_number

    # TODO: DO NOT COPY THIS SETTING INTO YOUR PRODUCTION DBS. It's only here to make testing this code easier!
    skip_final_snapshot = true

    tags = {
        Terraform = "true"
        Environment = "${local.env}"
        Region = local.environment_vars.locals.aws_region
    }
}