locals {
  shared      = read_terragrunt_config("${get_repo_root()}/shared/locals.hcl")
  environment = get_env("ENVIRONMENT")
}

terraform {
  before_hook "generate_be" {
    commands = ["init"]
    execute = [
      "${get_repo_root()}/scripts/write_backend.sh",
      "${local.shared.locals.root.locals.organization}",
      "${local.shared.locals.workspace_name}",
      "${local.shared.locals.environment_config.locals.subscription_id}",
      "${local.shared.locals.root.locals.project_name}-${local.environment}"
    ]
  }
}
