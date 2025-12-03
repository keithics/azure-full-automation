dependency "resource_group" {
  config_path = "../rg"
  mock_outputs = {
    resource_group_name = "mock-resource_group-output"
    resource_group_id   = "mock-resource_group-output"
  }

}

include "be" {
  path = "${get_repo_root()}/shared/be.hcl"
}

terraform {
  source = "${get_repo_root()}/modules/app-insights"
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }

}


locals {
  shared    = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
  unit_name = basename(get_terragrunt_dir())
}


inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  location            = local.shared.locals.root.locals.location
  name                = "appi-${local.shared.locals.name}"
  tags                = local.shared.locals.tags
}

# generate "unit-name-debug" {
#   path      = "unit-name.auto.tfvars"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<EOF
# name = "log-${local.shared.locals.name}"
# EOF
# }