locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env  = local.environment_vars.locals.environment
  name = "hzone1-${local.env}"
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.0.0"
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


inputs = {

    zones = {
        "terraform-aws-modules-example.com" = {
        comment = "hzone1-aws-modules-examples.com"
        tags = {
            env = "${local.env}"
    }

    tags = {
        Terraform = "true"
        Environment = "${local.env}"
        Region = local.environment_vars.locals.aws_region
    }
}