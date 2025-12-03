#!/bin/bash
set -euo pipefail

# Step 1: Run serverless first
echo "🚀 Deploying serverless..."
./scripts/deploy-stack.sh apply dev-101 serverless --non-interactive

# Step 2: Function to deploy post-network with retry if status is 1
deploy_post_network() {
  local max_retries=3
  local attempt=1

  while (( attempt <= max_retries )); do
    echo "🌐 Deploying post-network (attempt $attempt/$max_retries)..."
    if ./scripts/deploy-stack.sh apply dev-101 post-network --non-interactive; then
      echo "✅ post-network deployed successfully"
      return 0
    else
      status=$?
      if [[ $status -eq 1 ]]; then
        echo "⚠️ post-network failed with status 1 — retrying..."
        (( attempt++ ))
        sleep 5
      else
        echo "❌ post-network failed with non-retryable status $status"
        return $status
      fi
    fi
  done

  echo "❌ post-network failed after $max_retries attempts"
  return 1
}

# Step 3: Run post-network (with retry) and cicd in parallel
deploy_post_network &
PID1=$!

echo "⚙️ Deploying cicd..."
./scripts/deploy-stack.sh apply dev-101 cicd --non-interactive &
PID2=$!

# Step 4: Wait for both processes to finish
wait $PID1
wait $PID2

echo "🎉 All deployments completed."
