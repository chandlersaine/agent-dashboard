#!/bin/bash
# log-kb.sh — Add a knowledge base update
# Usage: ./scripts/log-kb.sh <title> <category> <summary> [source]
# Example: ./scripts/log-kb.sh "DFYD Booking Window Fix" strategy "Compressed booking window to 48-72hrs as highest-leverage fix" "Claude + Chandler"

TITLE="$1"
CATEGORY="$2"      # strategy | client | campaign | system
SUMMARY="$3"
SOURCE="${4:-Claude Code}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATA_FILE="data/knowledge.json"

if [ -z "$TITLE" ] || [ -z "$CATEGORY" ] || [ -z "$SUMMARY" ]; then
  echo "Usage: ./scripts/log-kb.sh <title> <category> <summary> [source]"
  exit 1
fi

python3 << EOF
import json, random, string
with open("$DATA_FILE", "r") as f:
    data = json.load(f)

kb_id = "kb-" + "".join(random.choices(string.ascii_lowercase + string.digits, k=6))

data["updates"].append({
    "id": kb_id,
    "title": "$TITLE",
    "category": "$CATEGORY",
    "summary": "$SUMMARY",
    "source": "$SOURCE",
    "timestamp": "$TIMESTAMP"
})

with open("$DATA_FILE", "w") as f:
    json.dump(data, f, indent=2)
print(f"KB update logged: {kb_id}")
EOF
