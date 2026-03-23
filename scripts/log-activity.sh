#!/bin/bash
# log-activity.sh — Add an entry to the activity log
# Usage: ./scripts/log-activity.sh <agent_id> <action> <status> <category> [detail]
# Example: ./scripts/log-activity.sh claude-code-01 "Deployed funnel report" complete campaign "Report covers Q1 performance"

AGENT_ID="$1"
ACTION="$2"
STATUS="$3"        # complete | in-progress | queued | failed
CATEGORY="$4"      # system | campaign | client | strategy
DETAIL="$5"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATA_FILE="data/activity.json"

if [ -z "$AGENT_ID" ] || [ -z "$ACTION" ] || [ -z "$STATUS" ]; then
  echo "Usage: ./scripts/log-activity.sh <agent_id> <action> <status> <category> [detail]"
  exit 1
fi

python3 << EOF
import json, random, string
with open("$DATA_FILE", "r") as f:
    data = json.load(f)

log_id = "log-" + "".join(random.choices(string.ascii_lowercase + string.digits, k=6))

data["log"].append({
    "id": log_id,
    "agent_id": "$AGENT_ID",
    "action": "$ACTION",
    "status": "$STATUS",
    "priority": "normal",
    "category": "${CATEGORY:-system}",
    "detail": "$DETAIL" if "$DETAIL" else None,
    "timestamp": "$TIMESTAMP"
})

with open("$DATA_FILE", "w") as f:
    json.dump(data, f, indent=2)
print(f"Activity logged: {log_id}")
EOF
