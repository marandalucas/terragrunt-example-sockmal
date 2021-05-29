# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment = "dev"

  # Automatically load region-level variables, because terragrunt don't allow global vars
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region   = local.region_vars.locals.aws_region

  vpc_cidr                = "10.1.0.0/16"
  vpc_azs                 = ["${local.aws_region}a", "${local.aws_region}b"]
  vpc_private_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
  vpc_public_subnets      = ["10.1.51.0/24", "10.1.52.0/24"]
  ingress_all_cidr_blocks = ["122.122.122.122/32"]

  # AMI - Nginx
  instance_default_ami      = "ami-001492455e2172c20"
  instance_default_type     =  "t2.micro"
  instance_default_key_name = "terra-key-pair"
  instance_default_number   = 1

  terra_tag = "true"
}