include "be" {
  path = "${get_repo_root()}/shared/be.hcl"
}

terraform {
  source = "${get_repo_root()}/modules/resource-group"
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }
}

locals {
  shared = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
}

inputs = {
  resource_group_name = "rg-${local.shared.locals.name}"
  location            = local.shared.locals.root.locals.location
  tags                = local.shared.locals.tags
}

