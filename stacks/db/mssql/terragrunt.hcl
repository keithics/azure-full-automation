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
  shared              = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
  entra_adapp_outputs = read_terragrunt_config("${local.shared.locals.output_dir}/entra/adapp/output.hcl")
  kv_outputs          = read_terragrunt_config("${local.shared.locals.output_dir}/security/kv/output.hcl")
  adapp               = local.entra_adapp_outputs.locals.adapp
  env                 = get_env("ENVIRONMENT")

  mssql_display_name = "adapp-${local.shared.locals.root.locals.project_name}-mssql-server-${local.shared.locals.env_name}"
  mssql_sp = {
    for name, sp in local.adapp.service_principal_ids :
    name => sp
    if name == local.mssql_display_name
  }


  mssql_client_id = local.mssql_sp[local.mssql_display_name].client_id
  mssql_object_id = local.mssql_sp[local.mssql_display_name].object_id
}

terraform {
  source = "${get_repo_root()}/modules/mssql"
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }
}


inputs = {
  mssql               = local.shared.locals.environment_config.locals.mssql
  key_vault_id        = local.kv_outputs.locals.kv.key_vault_ids["pulse-be-${local.env}"]
  ad_admin_username   = local.mssql_display_name
  ad_admin_object_id  = local.mssql_client_id
  tenant_id           = local.mssql_object_id
  resource_group_name = dependency.resource_group.outputs.resource_group_name
  location            = local.shared.locals.root.locals.location
  tags                = local.shared.locals.tags

}
