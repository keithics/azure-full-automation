dependency "key_vault" {
  config_path = "../kv"
  mock_outputs = {
    key_vault_ids = {
      "pulse-fe" = "mock-keyvault-id"
    }
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
  shared              = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
  appi_output         = read_terragrunt_config("${local.shared.locals.output_dir}/reports/appi/output.hcl")
  instrumentation_key = local.appi_output.locals.appi.instrumentation_key
  env                 = get_env("ENVIRONMENT")

  configs = [
    {
      name : "VITE-ENTRA-CLIENT-ID"
    },
    {
      name : "VITE-ENTRA-AUTHORITY"
    },
    {
      name : "VITE-GOOGLE-API-KEY"
    },
    {
      name : "VITE-META-WEATHER-API-KEY"
    },
    {
      name : "VITE-SENTRY-DNS"
    },

  ]


}

inputs = {
  secrets = concat(local.configs)
  kv_id   = dependency.key_vault.outputs.key_vault_ids["pulse-fe-${local.env}"]
  tags    = local.shared.locals.tags
}
