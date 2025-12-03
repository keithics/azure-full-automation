dependency "key_vault" {
  config_path = "../kv"
  mock_outputs = {
    key_vault_ids = {
      "pulse-be" = "mock-keyvault-id"
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
  mssql               = local.shared.locals.environment_config.locals.mssql
  appi_output         = read_terragrunt_config("${local.shared.locals.output_dir}/reports/appi/output.hcl")
  instrumentation_key = local.appi_output.locals.appi.instrumentation_key
  env                 = get_env("ENVIRONMENT")

  configs = [
    // MSSQL
    # {
    #   name : "MSSQL-SERVER", set in mssql/mssql-kvs
    # },
    {
      name : local.mssql.key_vault_administrator_login
      value : "sqlsqai-${local.env}"
    },
    {
      name : local.mssql.key_vault_administrator_password // MSSQL_PASSWORD
      random = true
    },
    // INTERNAL
    {
      name : "INTERNAL-API"
    },
    {
      name : "INTERNAL-TOKEN"
    },
    // EMAIL
    {
      name : "EMAIL-TOKEN"
    },
    {
      name : "EMAIL-DONOT-REPLY"
      value : ""
    },

    // SMS
    {
      name : "SMS-API",
    },

    // OTHER API Keys
    {
      name : "APPINSIGHTS-INSTRUMENTATIONKEY"
      value : local.instrumentation_key
    },

    {
      name : "EXTERNAL-AFTERSHIP-API"
    },
    {
      name : "AFTERSHIP-API-KEY"
    },

    {
      name : "NATIONAL-HIGHWAY-API-KEY"
    },
    {
      name : "NATIONAL-HIGHWAY-API"
    },
    {
      name : "GMAPS-API-KEY"
    },
    {
      name : "BASIC-AUTH-USER"
    },
    {
      name : "BASIC-AUTH-PASS"
    },
    {
      name : "WEATHER-API-KEY"
    },
    {
      name : "JWT-ISSUER-URI"
    },
    {
      name : "JWT-SET-ISSUER-URI"
    },
    {
      name : "SENTRY-AUTH-TOKEN"
    },
    {
      name : "SENTRY-DSN"
    }

  ]

}

inputs = {
  secrets = concat(local.configs)
  kv_id   = dependency.key_vault.outputs.key_vault_ids["pulse-be-${local.env}"]
  tags    = local.shared.locals.tags
}
