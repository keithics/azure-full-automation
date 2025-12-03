locals {
  env_name            = get_env("ENVIRONMENT")
  resource_group_type = get_env("MODULE_NAME")
  resource_group      = basename(get_original_terragrunt_dir())
  root                = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  environment_config  = read_terragrunt_config(get_env("ENV_CONFIG_PATH", ""))
  workspace_name      = "${local.root.locals.project_name}-${local.resource_group_type}-${local.resource_group}-${local.env_name}"
  name                = "${local.root.locals.project_name}-${local.resource_group_type}-${local.env_name}"
  output_dir          = "${get_repo_root()}/.outputs/${local.env_name}" // must be inline with scripts/deploy-stack.sh
  tags = {
    environment = local.env_name
    project     = local.root.locals.project_name
    stack       = local.resource_group_type
    workspace   = local.workspace_name
  }
}
