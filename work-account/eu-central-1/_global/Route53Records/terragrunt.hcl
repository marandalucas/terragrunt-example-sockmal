locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env  = local.environment_vars.locals.environment
  name = "hzone1-${local.env}"
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.0.0"
    }

include {
  path = find_in_parent_folders()
}


dependency "zone" {
    config_path  = "../../../_global/Route53HostedZone"
    mock_outputs = {
      private_subnets = ["private-subnet-id-az1", "private-subnet-id-az1"]
    }
}

dependency "eip" {

}

inputs = {

    zone_name = dependency.vpc.outputs.zone_id

    records = [
        {
        name    = "apigateway1"
        type    = "A"
        name    = ""
        type    = "A"
        ttl     = 3600
        records = [
            dependency.eip.outputs.eip_id,
        ]
        }
    ]

    tags = {
        Terraform = "true"
        Environment = "${local.env}"
        Region = local.environment_vars.locals.aws_region
    }
}