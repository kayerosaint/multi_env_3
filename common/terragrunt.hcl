locals {
  region  = "eu-west-3"
  project = "maks-k-one"
  domain  = "infra.maks-k-one.site"
}

inputs = {
  region  = local.region
  project = local.project
  domain  = local.domain
}

remote_state {
  backend  = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config   = {
    bucket         = "${local.project}-tf"
    key            = "terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "${local.project}-lock"
  }
}
