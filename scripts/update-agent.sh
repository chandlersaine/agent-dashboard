#!/bin/bash
# update-agent.sh — Update an agent's status in the dashboard
# Usage: ./scripts/update-agent.sh <agent_id> <status> <current_task> <last_action>
# Example: ./scripts/update-agent.sh claude-code-01 running "Building funnel report" "Started task"

AGENT_ID="$1"
STATUS="$2"
CURRENT_TASK="$3"
LAST_ACTION="$4"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATA_FILE="data/agents.json"

if [ -z "$AGENT_ID" ] || [ -z "$STATUS" ]; then
  echo "Usage: ./scripts/update-agent.sh <agent_id> <status> [current_task] [last_action]"
  exit 1
fi

# Use python for reliable JSON manipulation
python3 << EOF
import json, sys
with open("$DATA_FILE", "r") as f:
    data = json.load(f)

found = False
for agent in data["agents"]:
    if agent["id"] == "$AGENT_ID":
        agent["status"] = "$STATUS"
        agent["last_updated"] = "$TIMESTAMP"
        if "$CURRENT_TASK":
            agent["current_task"] = "$CURRENT_TASK" if "$CURRENT_TASK" != "null" else None
        if "$LAST_ACTION":
            agent["last_action"] = "$LAST_ACTION"
        if "$STATUS" == "idle":
            agent["tasks_completed_today"] = agent.get("tasks_completed_today", 0) + 1
        found = True
        break

if not found:
    print(f"Agent {sys.argv[1] if len(sys.argv) > 1 else '$AGENT_ID'} not found. Adding new agent.")
    data["agents"].append({
        "id": "$AGENT_ID",
        "name": "$AGENT_ID",
        "owner": "Chandler",
        "domain": "Unassigned",
        "status": "$STATUS",
        "current_task": "$CURRENT_TASK" if "$CURRENT_TASK" != "null" else None,
        "last_action": "$LAST_ACTION" or "Agent registered",
        "last_updated": "$TIMESTAMP",
        "tasks_completed_today": 0,
        "error_count": 0
    })

with open("$DATA_FILE", "w") as f:
    json.dump(data, f, indent=2)
print("Agent updated successfully.")
EOF
