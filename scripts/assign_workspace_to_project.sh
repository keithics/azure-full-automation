#!/bin/bash

set -e

# === DEFAULTS ===
ORG_NAME="Squarcle-Consulting-Ltd"
WORKSPACE_NAME="$(basename "$PWD")"

# === PARSE ARGUMENTS ===
while [[ $# -gt 0 ]]; do
  case $1 in
    --org)
      ORG_NAME="$2"
      shift 2
      ;;
    --project)
      PROJECT_NAME="$2"
      shift 2
      ;;
    --workspace)
      WORKSPACE_NAME="$2"
      shift 2
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# === VALIDATE REQUIRED ARGUMENTS ===
if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Usage: $0 --project <project-name> [--org <org-name>] [--workspace <workspace-name>]"
  exit 1
fi

# === AUTH FROM LOCAL TERRAFORM LOGIN ===
TFC_TOKEN=$(jq -r '.credentials."app.terraform.io".token' ~/.terraform.d/credentials.tfrc.json)
if [ "$TFC_TOKEN" == "null" ] || [ -z "$TFC_TOKEN" ]; then
  echo "❌ No Terraform Cloud token found. Run 'terraform login' first."
  exit 1
fi

AUTH_HEADER="Authorization: Bearer ${TFC_TOKEN}"
CONTENT_HEADER="Content-Type: application/vnd.api+json"

echo "🔍 Org: $ORG_NAME"
echo "🔍 Project: $PROJECT_NAME"
echo "🔍 Workspace: $WORKSPACE_NAME"

# === 1. Get Project ID ===
PROJECT_ID=$(curl -s \
  -H "${AUTH_HEADER}" \
  -H "${CONTENT_HEADER}" \
  "https://app.terraform.io/api/v2/organizations/${ORG_NAME}/projects" | \
  jq -r ".data[] | select(.attributes.name == \"${PROJECT_NAME}\") | .id")

if [ -z "$PROJECT_ID" ]; then
  echo "❌ Project '${PROJECT_NAME}' not found in org '${ORG_NAME}'."
  exit 1
fi
echo "✅ Found Project ID: $PROJECT_ID"

# === 2. Get Workspace ID ===
WORKSPACE_ID=$(curl -s \
  -H "${AUTH_HEADER}" \
  -H "${CONTENT_HEADER}" \
  "https://app.terraform.io/api/v2/organizations/${ORG_NAME}/workspaces/${WORKSPACE_NAME}" | \
  jq -r ".data.id")

if [ -z "$WORKSPACE_ID" ]; then
  echo "❌ Workspace '${WORKSPACE_NAME}' not found in org '${ORG_NAME}'."
  exit 1
fi
echo "✅ Found Workspace ID: $WORKSPACE_ID"

# === 3. Assign Workspace to Project ===
curl -s -X PATCH \
  -H "${AUTH_HEADER}" \
  -H "${CONTENT_HEADER}" \
  "https://app.terraform.io/api/v2/workspaces/${WORKSPACE_ID}" \
  -d @- <<EOF
{
  "data": {
    "type": "workspaces",
    "id": "${WORKSPACE_ID}",
    "attributes": {},
    "relationships": {
      "project": {
        "data": {
          "type": "projects",
          "id": "${PROJECT_ID}"
        }
      }
    }
  }
}
EOF

echo "🎉 Workspace '${WORKSPACE_NAME}' assigned to project '${PROJECT_NAME}' in org '${ORG_NAME}'."
