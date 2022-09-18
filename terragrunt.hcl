locals {
  workspace = run_cmd("--terragrunt-quiet", "terraform", "workspace", "show")
  common    = read_terragrunt_config("common/terragrunt.hcl")
}

inputs = {
  region      = local.common.inputs.region
  project     = local.common.inputs.project
  env         = local.workspace
}

remote_state = local.common.remote_state

terraform {
  extra_arguments "conditional_vars" {
    commands = get_terraform_commands_that_need_vars()

    required_var_files = [
      "tfvars/${local.workspace}/terraform.tfvars"
    ]
  }

  after_hook "upload_vars" {
    commands     = ["apply"]
    execute      = ["make", "push_vars"]
    run_on_error = false
  }
}
