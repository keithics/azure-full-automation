#!/bin/bash

# Usage: ./delete-azure-apps.sh <search_term_1> [search_term_2 ...]

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <search_term_1> [search_term_2 ...]"
  exit 1
fi

SEARCH_TERMS=("$@")

for TERM in "${SEARCH_TERMS[@]}"; do
  echo "🔍 Searching for Azure App Registrations matching: '$TERM'..."
  echo

  mapfile -t apps < <(az ad app list --all --query "[?contains(displayName, '$TERM')].[displayName, appId, id]" -o tsv)

  if [ ${#apps[@]} -eq 0 ]; then
    echo "No matching App Registrations found for: $TERM"
    continue
  fi

  for app in "${apps[@]}"; do
    name=$(echo "$app" | awk -F'\t' '{print $1}')
    appId=$(echo "$app" | awk -F'\t' '{print $2}')
    objectId=$(echo "$app" | awk -F'\t' '{print $3}')

    echo "Found App Registration:"
    echo "  Name:      $name"
    echo "  App ID:    $appId"
    echo "  Object ID: $objectId"
    echo

    read -p "❓ Delete this App Registration? [y/N] " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      echo "🗑 Deleting App Registration..."
      az ad app delete --id "$appId"
      echo "✅ Deleted: $name"
    else
      echo "⏭ Skipped: $name"
    fi

    echo "---------------------------"
  done
done
