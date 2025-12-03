include "be" {
  path = "${get_repo_root()}/shared/be.hcl"
}

locals {
  shared = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
}

terraform {
  source = "${get_repo_root()}/modules/ad-app"
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }
}

inputs = {
  entra_apps = local.shared.locals.environment_config.locals.entra_apps
  tags       = local.shared.locals.tags
}
