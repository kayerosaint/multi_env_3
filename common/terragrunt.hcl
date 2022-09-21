locals {
  workspace   = run_cmd("--terragrunt-quiet", "terraform", "workspace", "show")
  region      = "eu-west-3"
  project     = "maks-k-one"
  domain      = "infra.maks-k-one.site"
  app         = "app"
  containers  = {
    web = {
      name = "web"
    }
  }
  bucket = "${local.project}-tf"
}
inputs = {
  region      = local.region
  project     = local.project
  domain      = local.domain
  app         = local.app
  containers  = local.containers
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

terraform {
  extra_arguments "conditional_vars" {
    commands = get_terraform_commands_that_need_vars()

    required_var_files = [
      "../tfvars/terraform.tfvars"
    ]
  }

  after_hook "upload_vars" {
    commands     = ["apply"]
    execute      = ["make", "push_vars", "-f", "../Makefile"]
    run_on_error = false
  }
}
