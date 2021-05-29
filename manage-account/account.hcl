# Configuramos las variables de la cuenta de aws para que se configuren en el terragrunt.hcl de la raiz 
# donde tenemos configurado el bucket de s3 como almacenamiento para el estado de la infra.

locals {
  account_name   = "manage-account"
  aws_account_id = "331312421726" # AWS account ID
  aws_profile    = "manage-account"
}