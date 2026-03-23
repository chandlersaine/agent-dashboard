# Agent Command Center

Operational dashboard for managing AI agent fleet. Deployed via GitHub Pages. Updated by Claude Code via simple shell scripts + git push.

## Live Dashboard

Once deployed: `https://<your-username>.github.io/agent-dashboard/`

---

## Setup (One-Time)

### 1. Push this repo to GitHub

```bash
cd agent-dashboard
git init
git add .
git commit -m "Initial dashboard setup"
git remote add origin git@github.com:<your-username>/agent-dashboard.git
git branch -M main
git push -u origin main
```

### 2. Enable GitHub Pages

1. Go to repo **Settings → Pages**
2. Source: **GitHub Actions**
3. The deploy workflow will run automatically on push

### 3. Make scripts executable

```bash
chmod +x scripts/*.sh
```

---

## How Claude Code Updates the Dashboard

All updates follow the same pattern: **run script → git commit → git push**. The GitHub Pages site rebuilds automatically (~1 min).

### Update Agent Status

```bash
./scripts/update-agent.sh <agent_id> <status> "<current_task>" "<last_action>"

# Examples:
./scripts/update-agent.sh claude-code-01 running "Building Meta ad report" "Started report generation"
./scripts/update-agent.sh claude-code-01 idle null "Completed Meta ad report"
```

**Status values:** `running` | `idle` | `blocked` | `error`

### Log Activity

```bash
./scripts/log-activity.sh <agent_id> "<action>" <status> <category> "[detail]"

# Examples:
./scripts/log-activity.sh claude-code-01 "Generated Q1 ad performance report" complete campaign "Covers all 50 client accounts"
./scripts/log-activity.sh claude-code-01 "Analyzing lead quality by creative" in-progress client
```

**Status values:** `complete` | `in-progress` | `queued` | `failed`
**Category values:** `system` | `campaign` | `client` | `strategy`

### Log Knowledge Base Update

```bash
./scripts/log-kb.sh "<title>" <category> "<summary>" "[source]"

# Examples:
./scripts/log-kb.sh "DFYD Booking Window Compression" strategy "Identified 48-72hr booking window as highest-leverage fix for conversion" "Claude + Chandler"
./scripts/log-kb.sh "New Client Onboarded: Jason" client "AI-powered direct mail company targeting RE investors. Full marketing strategy delivered." "Chandler"
```

### Manage Alerts

```bash
./scripts/log-alert.sh add <agent_id> <severity> "<message>"
./scripts/log-alert.sh clear <alert_id>
./scripts/log-alert.sh clear-all

# Examples:
./scripts/log-alert.sh add claude-code-01 warning "Meta API rate limit at 80%"
./scripts/log-alert.sh clear-all
```

**Severity values:** `critical` | `warning`

### Push Updates Live

After any script runs:

```bash
git add data/
git commit -m "Dashboard update: <brief description>"
git push
```

---

## Adding a New Agent

Either use the update script with a new ID (it auto-registers):

```bash
./scripts/update-agent.sh new-agent-02 idle null "Agent registered"
```

Or manually edit `data/agents.json` to set name, domain, etc:

```json
{
  "id": "meta-ads-agent",
  "name": "Meta Ads Automator",
  "owner": "Chandler",
  "domain": "Media Buying",
  "status": "idle",
  "current_task": null,
  "last_action": "Agent registered",
  "last_updated": "2026-03-23T12:00:00Z",
  "tasks_completed_today": 0,
  "error_count": 0
}
```

---

## Data Schema Reference

### agents.json
| Field | Type | Description |
|-------|------|-------------|
| id | string | Unique agent identifier |
| name | string | Display name |
| owner | string | Who owns this agent |
| domain | string | Business area (e.g., "Media Buying", "Sales Ops") |
| status | string | running / idle / blocked / error |
| current_task | string|null | What it's doing right now |
| last_action | string | Most recent completed action |
| last_updated | ISO 8601 | Last status change |
| tasks_completed_today | int | Counter, resets daily |
| error_count | int | Cumulative errors |

### activity.json
| Field | Type | Description |
|-------|------|-------------|
| id | string | Unique log ID |
| agent_id | string | Which agent performed this |
| action | string | What happened |
| status | string | complete / in-progress / queued / failed |
| priority | string | normal / high / urgent |
| category | string | system / campaign / client / strategy |
| detail | string|null | Additional context |
| timestamp | ISO 8601 | When it happened |

### knowledge.json
| Field | Type | Description |
|-------|------|-------------|
| id | string | Unique KB entry ID |
| title | string | Short title |
| category | string | strategy / client / campaign / system |
| summary | string | What changed and why it matters |
| source | string | Who/what generated this update |
| timestamp | ISO 8601 | When it was logged |

### alerts.json
| Field | Type | Description |
|-------|------|-------------|
| id | string | Unique alert ID |
| agent_id | string | Which agent raised the alert |
| severity | string | critical / warning |
| message | string | What's wrong |
| timestamp | ISO 8601 | When the alert was raised |

---

## File Structure

```
agent-dashboard/
├── index.html              # Dashboard frontend
├── data/
│   ├── agents.json         # Agent registry
│   ├── activity.json       # Activity log
│   ├── knowledge.json      # KB changelog
│   └── alerts.json         # Alerts
├── scripts/
│   ├── update-agent.sh     # Update agent status
│   ├── log-activity.sh     # Log activity
│   ├── log-kb.sh           # Log KB update
│   └── log-alert.sh        # Manage alerts
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Pages auto-deploy
└── README.md
```
