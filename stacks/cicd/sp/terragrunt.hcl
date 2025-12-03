include "be" {
  path = "${get_repo_root()}/shared/be.hcl"
}

locals {
  shared = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
  env    = get_env("ENVIRONMENT")

  github_cicd_sp       = local.shared.locals.environment_config.locals.github_cicd_sp
  main_kv_sp           = local.shared.locals.environment_config.locals.main_kv_sp
  subscription_id      = local.shared.locals.environment_config.locals.subscription_id

  id_outputs = read_terragrunt_config("${local.shared.locals.output_dir}/security/id/output.hcl")
  uami_id    = local.id_outputs.locals.id.identity_ids["id-pulse-security-${local.env}"]

  repos = local.shared.locals.environment_config.locals.container_apps.repos


}

terraform {
  source = "${get_repo_root()}/modules/role-assignment"
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }
}

inputs = {
  assignments = flatten(
    [
      [
        for sp in local.github_cicd_sp : {
          principal_id         = sp
          role_definition_name = "Contributor"
          scope                = "/subscriptions/${local.subscription_id}"
        }
      ],
      [
        for sp in local.main_kv_sp : {
          principal_id         = sp
          role_definition_name = "Reader"
          scope                = "/subscriptions/${local.subscription_id}"
        }
      ],
      [
        for sp in local.github_cicd_sp : {
          principal_id         = sp
          role_definition_name = "Reader"
          scope                = local.uami_id
        }
      ]
    ]

    # assignments = [
    #   {
    #     principal_id         = local.github_cicd_sp
    #     role_definition_name = "Contributor"
    #     scope                = "/subscriptions/${local.subscription_id}"
    #   },
    #   {
    #     principal_id         = "d5d4a21f-6bb0-462d-88c3-6395e457b3d2"
    #     role_definition_name = "Reader"
    #     scope                = "/subscriptions/${local.subscription_id}"
    #   },
    #   # {
    #   #   principal_id         = local.github_cicd_sp
    #   #   role_definition_name = "Contributor"
    #   #   scope                = "/subscriptions/${local.subscription_id_dev}"
    #   # },
    #   {
    #     principal_id         = local.github_cicd_sp
    #     role_definition_name = "Reader"
    #     scope                = local.uami_id
    #   }
    # ]
  )

}
