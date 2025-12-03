include "be" {
  path = "${get_repo_root()}/shared/be.hcl"
}

locals {
  shared = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
  env    = get_env("ENVIRONMENT")

  id_outputs = read_terragrunt_config("${local.shared.locals.output_dir}/security/id/output.hcl")
  uami_sid   = local.id_outputs.locals.id.principal_ids["id-pulse-security-${local.env}"]

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
  assignments = [
    {
      principal_id         = local.github_cicd_sp
      role_definition_name = "Contributor"
      scope                = "/subscriptions/${local.subscription_id}"
    }
  ]
}
