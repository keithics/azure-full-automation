#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/deploy-all.sh apply shared-dev
# Example: ./scripts/deploy-all.sh apply shared-dev

ACTION="${1:-apply}"
ENVIRONMENT="${2:-shared-dev}"

STACKS=(
  "entra"
  "reports"
  "security"
  "cicd"
)

for STACK in "${STACKS[@]}"; do
  echo "=============================="
  echo "Running: ./scripts/deploy-stack.sh $ACTION $ENVIRONMENT $STACK"
  echo "=============================="
  ./scripts/deploy-stack.sh "$ACTION" "$ENVIRONMENT" "$STACK" --non-interactive
  echo "✅ Completed $STACK"
done

echo "🎉 All stacks deployed successfully!"
