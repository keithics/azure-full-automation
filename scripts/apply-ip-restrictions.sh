#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT=$1

# === fixed paths ===
REL_APIM_JSON=".outputs/${ENVIRONMENT}/post-network/apim/output.json"
REL_CA_JSON=".outputs/${ENVIRONMENT}/serverless/ca/output.json"
MAX_PARALLEL=8
# ====================

# derive absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APIM_JSON="$PROJECT_ROOT/$REL_APIM_JSON"
CA_JSON="$PROJECT_ROOT/$REL_CA_JSON"

# prerequisites
for cmd in jq az; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is required." >&2
    exit 1
  fi
done

for f in "$APIM_JSON" "$CA_JSON"; do
  if [ ! -f "$f" ]; then
    echo "Error: Cannot find '$f'" >&2
    exit 1
  fi
done

# get the APIM IP and append /32
RAW_IP=$(jq -r '.apim_public_ip_id.value[0]' "$APIM_JSON")
if [ -z "$RAW_IP" ] || [ "$RAW_IP" = "null" ]; then
  echo "Error: no IP found in $APIM_JSON" >&2
  exit 1
fi
IP_CIDR="$RAW_IP/32"

# fetch all Container App IDs (one per line)
IDS=$(jq -r '.container_app_ids.value | to_entries[].value' "$CA_JSON")
if [ -z "$IDS" ]; then
  echo "Error: no container_app_ids found in $CA_JSON" >&2
  exit 1
fi

echo "🔒 Applying allow-only rule for $IP_CIDR to all container apps in parallel…"

# throttle helper
wait_for_slot(){
  while (( $(jobs -rp | wc -l) >= MAX_PARALLEL )); do
    sleep 0.1
  done
}

for ID in $IDS; do
  wait_for_slot
  {
    echo "  • Configuring $ID"
    az containerapp ingress access-restriction set \
      --ids "$ID" \
      --rule-name "Allow APIM IP" \
      --ip-address "$IP_CIDR" \
      --description "Allow only APIM ID : $IP_CIDR" \
      --action Allow \
    && echo "    ✓ $ID" \
    || echo "    ✗ $ID (failed)"
  } &
done

wait
echo "✅ Done. All container apps now restrict ingress to $IP_CIDR."
