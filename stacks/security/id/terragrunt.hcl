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

locals {
  shared = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/user-identity"
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }
}


inputs = {
  identity_names = [
    "id-${local.shared.locals.name}"
  ]
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  location            = local.shared.locals.root.locals.location
  tags                = local.shared.locals.tags
}