#!/bin/bash
set -e

# === Arguments ===
ORG_NAME=$1
WORKSPACE_NAME=$2
SUBSCRIPTION_ID=$3
PROJECT_NAME=$4
BACKEND_FILE="be.tf"

# === Load Terraform Cloud Token ===
TFC_TOKEN=$(jq -r '.credentials."app.terraform.io".token' ~/.terraform.d/credentials.tfrc.json)
if [ "$TFC_TOKEN" == "null" ] || [ -z "$TFC_TOKEN" ]; then
  echo "❌ No Terraform Cloud token found. Run 'terraform login' first."
  exit 1
fi

AUTH_HEADER="Authorization: Bearer ${TFC_TOKEN}"
CONTENT_HEADER="Content-Type: application/vnd.api+json"

# === 1. Check if Project Exists ===
PROJECT_ID=$(curl -s \
  -H "${AUTH_HEADER}" \
  -H "${CONTENT_HEADER}" \
  "https://app.terraform.io/api/v2/organizations/${ORG_NAME}/projects" | \
  jq -r ".data[] | select(.attributes.name == \"${PROJECT_NAME}\") | .id")

if [ -z "$PROJECT_ID" ]; then
  echo "❌ Project '${PROJECT_NAME}' not found in organization '${ORG_NAME}'."
  echo "You need to create the project manually in terracloud. https://app.terraform.io/app/Squarcle-Consulting-Ltd/projects"
  exit 1
fi
echo "✅ Project '${PROJECT_NAME}' found. ID: ${PROJECT_ID}"

# === 2. Check if Workspace Exists ===
WORKSPACE_RESPONSE=$(curl -s \
  -H "${AUTH_HEADER}" \
  -H "${CONTENT_HEADER}" \
  "https://app.terraform.io/api/v2/organizations/${ORG_NAME}/workspaces/${WORKSPACE_NAME}")

WORKSPACE_ID=$(echo "$WORKSPACE_RESPONSE" | jq -r ".data.id" 2>/dev/null || true)

if [ -n "$WORKSPACE_ID" ] && [ "$WORKSPACE_ID" != "null" ]; then
  # === 2a. Workspace exists — check project assignment ===
  CURRENT_PROJECT_ID=$(echo "$WORKSPACE_RESPONSE" | jq -r ".data.relationships.project.data.id // empty")
  if [ "$CURRENT_PROJECT_ID" != "$PROJECT_ID" ]; then
    echo "ℹ️ Workspace '${WORKSPACE_NAME}' is in a different project. Reassigning..."

    curl -s -X PATCH \
      -H "${AUTH_HEADER}" \
      -H "${CONTENT_HEADER}" \
      "https://app.terraform.io/api/v2/workspaces/${WORKSPACE_ID}" \
      -d @- >/dev/null <<EOF
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

    echo "✅ Workspace '${WORKSPACE_NAME}' moved to project '${PROJECT_NAME}'."
  else
    echo "✅ Workspace '${WORKSPACE_NAME}' already in correct project '${PROJECT_NAME}'."
  fi
else
  echo "ℹ️ Workspace '${PROJECT_NAME}'-'${WORKSPACE_NAME}' does not exist. No action taken."
fi

# === 3. Create Backend File ===
echo "📄 Creating backend file (${WORKSPACE_NAME}) at $(pwd)/$BACKEND_FILE ..."

cat > "$BACKEND_FILE" <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.31.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "${ORG_NAME}"

    workspaces {
      name = "${WORKSPACE_NAME}"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "${SUBSCRIPTION_ID}"
}
EOF

echo "✅ Created $BACKEND_FILE successfully. (${WORKSPACE_NAME})"
