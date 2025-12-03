#!/bin/bash
set -euo pipefail

# ANSI color codes
RED="\033[0;31m"
RESET="\033[0m"

# Check if action, environment, and module are passed
if [ "$#" -lt 3 ]; then
  printf "${RED}Usage: $0 <action> <env-name> <module-name> <unit-name>${RESET}\n"
  printf "Example: $0 scripts/destroy-unit.sh dev-100 network agw\n"
  exit 1
fi

ENVIRONMENT=$1
MODULE=$2
UNIT=$3

ENV_CONFIG_PATH="${PWD}/environments/${ENVIRONMENT}/config.hcl"

# Check if parent directory exists
if [ ! -d "$(dirname "$ENV_CONFIG_PATH")" ]; then
  echo "Error: Parent directory does not exist: $(dirname "$ENV_CONFIG_PATH")"
  exit 1
fi

# Check if config file exists
if [ ! -f "$ENV_CONFIG_PATH" ]; then
  echo "Error: Config file does not exist: $ENV_CONFIG_PATH"
  exit 1
fi


export ENV_CONFIG_PATH=$ENV_CONFIG_PATH
export ENVIRONMENT=$ENVIRONMENT
export MODULE_NAME=$MODULE


UNIT_PATH="${PWD}/stacks/${MODULE}/$UNIT"

if [ ! -d "$UNIT_PATH" ]; then
  printf "${RED}Unit path '${UNIT_PATH}' not found. Exiting.${RESET}\n"
  exit 1
fi

(
  cd "$UNIT_PATH"
  printf "${RED}Destroying Unit path '${UNIT_PATH}' ${RESET}\n"
  echo $ENVIRONMENT
  echo $MODULE
  echo $ENV_CONFIG_PATH
  terragrunt destroy
)
exit 0

