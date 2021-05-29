
locals {
  # Automáticamente carga las variables a nivel de cuenta.
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automáticamente carga las variables a nivel de region.
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automáticamente carga las variables a nivel de enterno.
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Acceso a variables sencillamente.
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
}

# Generamos el provider de AWS.
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  # Solo permitimos operar con un ID de cuentas de AWS específicas.
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "socks-terragrunt-terraform-state-${local.account_name}-${local.aws_region}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {

  # Nos aseguraremos que el paralelismo no excede el de dos modulos a la vez.
  extra_arguments "reduced_parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=2"]
  }

  before_hook "auto_init" {
    commands = ["validate", "plan", "apply", "destroy", "workspace", "output", "import"]
    execute  = ["terraform", "init"]
  }

  before_hook "before_hook" {
    commands     = ["plan", "apply"]
    execute      = ["echo", "Will run Terraform"]
  }

  after_hook "after_hook" {
    commands     = ["apply"]
    execute      = ["echo", "Finished applying Terraform successfully!"]
    run_on_error = false
  }
}

inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)