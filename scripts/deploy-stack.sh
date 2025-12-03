#!/bin/bash
set -euo pipefail

# ANSI color codes
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Check if action, environment, and module are passed
if [ "$#" -lt 3 ]; then
  printf "${RED}Usage: $0 <action> <env-name> <module-name>${RESET}\n"
  printf "Example: $0 plan dev-001 serverless\n"
  printf "Example: $0 apply dev-001 serverless\n"
  printf "Example: $0 apply dev-001 serverless\n --non-interactive"
  exit 1
fi

ACTION=$1
ENVIRONMENT=$2
MODULE=$3

ENV_CONFIG_PATH="${PWD}/environments/${ENVIRONMENT}/config.hcl"
SCRIPT_PATH="${PWD}/scripts"
MODULE_PATH="./stacks/${MODULE}"

TF_LOG=ERROR

# Check if module path exists
if [ ! -d "$MODULE_PATH" ]; then
  printf "${RED}Module path '${MODULE_PATH}' not found. Exiting.${RESET}\n"
  exit 1
fi

printf "${GREEN}🚀 Deploying module '${MODULE}' to environment '${ENVIRONMENT}' with action '${ACTION}'${RESET}\n"

OUTPUT_ROOT="${PWD}/.outputs/${ENVIRONMENT}/${MODULE}"
mkdir -p "$OUTPUT_ROOT"

(
  cd "$MODULE_PATH"
  [ -d .terragrunt-stack ] && rm -rf .terragrunt-stack
  [ -f .terraform.lock.hcl ] && rm .terraform.lock.hcl

  export ENV_CONFIG_PATH=$ENV_CONFIG_PATH
  export ENVIRONMENT=$ENVIRONMENT
  export MODULE_NAME=$MODULE

  shift 3
  terragrunt stack run "$ACTION" "$@"

  printf "${YELLOW}📤 Exporting outputs for each unit in stack '${MODULE}'...${RESET}\n"

  find .terragrunt-stack -mindepth 1 -maxdepth 1 -type d -print0 | while IFS= read -r -d '' UNIT_DIR; do
    UNIT_NAME=$(basename "$UNIT_DIR")
    OUTPUT_DIR="${OUTPUT_ROOT}/${UNIT_NAME}"

    # clean up
    rm -rf "$OUTPUT_DIR"


    mkdir -p "$OUTPUT_DIR"

    pushd "$UNIT_DIR" > /dev/null
    terragrunt output -json > "${OUTPUT_DIR}/output.json"
    popd > /dev/null

     node "${SCRIPT_PATH}/node/parse-output.js" "${OUTPUT_DIR}/output.json"


    printf "${GREEN}✅  Exported: ${OUTPUT_DIR}/output.hcl${RESET}\n"
  done
)

# Final success message
printf "${GREEN}🎉 Module '${MODULE}' finished '${ACTION}' successfully!${RESET}\n"
