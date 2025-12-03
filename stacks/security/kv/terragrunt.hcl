dependency "resource_group" {
  config_path = "../rg"
  mock_outputs = {
    resource_group_name = "mock-resource_group-output"
    resource_group_id   = "mock-resource_group-output"
  }

}


dependency "id" {
  config_path = "../id"
  mock_outputs = {
    principal_ids = "mock-principal_ids"
  }

}

include "be" {
  path = "${get_repo_root()}/shared/be.hcl"
}

locals {
  shared = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
  env    = get_env("ENVIRONMENT")

  key_vaults        = local.shared.locals.environment_config.locals.key_vaults
  default_owners    = local.shared.locals.environment_config.locals.default_owners
  default_owners_sp = local.shared.locals.environment_config.locals.default_owners_sp
  key_vaults_processed = [
    for kv in local.key_vaults : {
      name                       = kv.name
      sku                        = kv.sku
      tenant_id                  = local.shared.locals.environment_config.locals.top_level_tenant
      enable_rbac                = kv.enable_rbac
      purge_protection_enabled   = kv.purge_protection_enabled
      soft_delete_retention_days = kv.soft_delete_retention_days
      readonly_app               = kv.readonly_app
      officer_app                = kv.officer_app

    }
  ]
}

terraform {
  source = "${get_repo_root()}/modules/key-vault"
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }
}


inputs = {
  key_vaults          = local.key_vaults_processed
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  location            = local.shared.locals.root.locals.location
  tags                = local.shared.locals.tags
  default_owners      = local.default_owners
  default_owners_sp   = local.default_owners_sp
  uami_principal_id   = dependency.id.outputs.principal_ids["id-pulse-security-${local.env}"]
}
