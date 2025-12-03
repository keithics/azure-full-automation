dependency "mssql" {
  config_path = "../mssql"
  mock_outputs = {
    mssql_server_name = "mock mssql_server_name"
  }

}

include "be" {
  path = "${get_repo_root()}/shared/be.hcl"
}

terraform {
  source = "${get_repo_root()}/modules/key-vault-secrets"
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }
}

locals {
  shared    = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
  kv_output = read_terragrunt_config("${local.shared.locals.output_dir}/security/kv/output.hcl")
  env       = get_env("ENVIRONMENT")

}

inputs = {
  secrets = [
    {
      name : "MSSQL-SERVER-NAME"
      value : dependency.mssql.outputs.mssql_server_name // dependency cannot be used inside locals
    }
  ]
  kv_id = local.kv_output.locals.kv.key_vault_ids["pulse-be-${local.env}"]
  tags  = local.shared.locals.tags
}
