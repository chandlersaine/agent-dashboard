#!/bin/bash
# log-alert.sh — Add or clear alerts
# Usage: ./scripts/log-alert.sh add <agent_id> <severity> <message>
# Usage: ./scripts/log-alert.sh clear <alert_id>
# Usage: ./scripts/log-alert.sh clear-all
# Example: ./scripts/log-alert.sh add claude-code-01 warning "Rate limit approaching on Meta API"

COMMAND="$1"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATA_FILE="data/alerts.json"

python3 << EOF
import json, random, string, sys
with open("$DATA_FILE", "r") as f:
    data = json.load(f)

cmd = "$COMMAND"

if cmd == "add":
    alert_id = "alert-" + "".join(random.choices(string.ascii_lowercase + string.digits, k=6))
    data["alerts"].append({
        "id": alert_id,
        "agent_id": "$2",
        "severity": "$3",    # critical | warning
        "message": "$4",
        "timestamp": "$TIMESTAMP"
    })
    print(f"Alert added: {alert_id}")
elif cmd == "clear":
    data["alerts"] = [a for a in data["alerts"] if a["id"] != "$2"]
    print(f"Alert cleared: $2")
elif cmd == "clear-all":
    data["alerts"] = []
    print("All alerts cleared.")
else:
    print("Usage: ./scripts/log-alert.sh [add|clear|clear-all] ...")
    sys.exit(1)

with open("$DATA_FILE", "w") as f:
    json.dump(data, f, indent=2)
EOF
