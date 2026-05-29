#!/usr/bin/env bash
set -euo pipefail

AUTH_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode"
AUTH_FILE="$AUTH_DIR/auth.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_CONFIG_FILE="$SCRIPT_DIR/opencode.json"
GLOBAL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
GLOBAL_CONFIG_FILE="$GLOBAL_CONFIG_DIR/opencode.json"
AGENTS_SOURCE_DIR="$SCRIPT_DIR/agents"
PROJECT_AGENTS_DIR="$SCRIPT_DIR/.opencode/agents"
GLOBAL_AGENTS_DIR="$GLOBAL_CONFIG_DIR/agents"
LEGACY_AGENT_FILES=(
  "pri-ask.md"
  "pri-plan.md"
  "pri-build.md"
  "pri-debug.md"
  "sub-lg-repo-search.md"
  "sub-lg-web-search.md"
  "sub-lg-task-recon.md"
  "sub-lg-task-lister.md"
  "sub-lg-dependency-mapper.md"
  "sub-lg-crew-manager.md"
  "sub-lg-validation-planner.md"
  "sub-lg-plan-state-writer.md"
  "sub-lg-plan-reviewer.md"
  "sub-lg-builder.md"
  "sub-lg-qa.md"
  "sub-lg-release.md"
  "sub-lg-analysis.md"
  "sub-lg-ranking-fixes.md"
  "sub-lg-debugger.md"
)
CONFIG_FILES=()
AGENT_TARGET_DIRS=()

ensure_opencode() {
  if command -v opencode >/dev/null 2>&1; then
    return
  fi

  printf "OpenCode not found. Installing...\n"

  if command -v brew >/dev/null 2>&1; then
    brew install anomalyco/tap/opencode
  elif command -v npm >/dev/null 2>&1; then
    npm install -g opencode-ai
  elif command -v bun >/dev/null 2>&1; then
    bun install -g opencode-ai
  elif command -v pnpm >/dev/null 2>&1; then
    pnpm install -g opencode-ai
  elif command -v yarn >/dev/null 2>&1; then
    yarn global add opencode-ai
  else
    printf "Error: no supported installer found (brew, npm, bun, pnpm, yarn).\n" >&2
    printf "Install OpenCode manually: https://opencode.ai/docs/#install\n" >&2
    exit 1
  fi

  if ! command -v opencode >/dev/null 2>&1; then
    printf "Error: OpenCode install completed but 'opencode' is not on PATH.\n" >&2
    printf "Restart your shell and run this script again.\n" >&2
    exit 1
  fi
}

API_KEY="${API_KEY:-}"
RESOURCE_NAME="${RESOURCE_NAME:-${SECRET_VALUE:-}}"
SCOPE="${SCOPE:-}"
USE_EXISTING_KEY="${USE_EXISTING_KEY:-}"
USE_EXISTING_RESOURCE_NAME="${USE_EXISTING_RESOURCE_NAME:-}"
COPY_REPO_AGENTS_TO_GLOBAL="${COPY_REPO_AGENTS_TO_GLOBAL:-}"
CLEAN_GLOBAL_AGENTS="${CLEAN_GLOBAL_AGENTS:-}"
DEPLOY_PROJECT_AGENTS=0
DEPLOY_GLOBAL_AGENTS=0

ensure_opencode

if [ -z "$SCOPE" ]; then
  printf "Setup scope [project/global/both] (default: project): "
  read -r SCOPE
fi

SCOPE="${SCOPE:-project}"

case "$SCOPE" in
  project)
    CONFIG_FILES=("$PROJECT_CONFIG_FILE")
    DEPLOY_PROJECT_AGENTS=1
    ;;
  global)
    mkdir -p "$GLOBAL_CONFIG_DIR"
    cp "$PROJECT_CONFIG_FILE" "$GLOBAL_CONFIG_FILE"
    CONFIG_FILES=("$GLOBAL_CONFIG_FILE")
    DEPLOY_GLOBAL_AGENTS=1
    ;;
  both)
    mkdir -p "$GLOBAL_CONFIG_DIR"
    cp "$PROJECT_CONFIG_FILE" "$GLOBAL_CONFIG_FILE"
    CONFIG_FILES=("$PROJECT_CONFIG_FILE" "$GLOBAL_CONFIG_FILE")
    DEPLOY_PROJECT_AGENTS=1
    DEPLOY_GLOBAL_AGENTS=1
    ;;
  *)
    printf "Error: SCOPE must be 'project', 'global', or 'both'.\n" >&2
    exit 1
    ;;
esac

if [ "$DEPLOY_GLOBAL_AGENTS" -eq 1 ]; then
  if [ -z "$COPY_REPO_AGENTS_TO_GLOBAL" ]; then
    printf "Copy repository agents to global location? [Y/n]: "
    read -r COPY_REPO_AGENTS_TO_GLOBAL
  fi
  case "${COPY_REPO_AGENTS_TO_GLOBAL:-Y}" in
    y|Y|yes|YES|"")
      DEPLOY_GLOBAL_AGENTS=1
      ;;
    n|N|no|NO)
      DEPLOY_GLOBAL_AGENTS=0
      ;;
    *)
      printf "Error: COPY_REPO_AGENTS_TO_GLOBAL must be y/yes or n/no.\n" >&2
      exit 1
      ;;
  esac
fi

AGENT_TARGET_DIRS=()
if [ "$DEPLOY_PROJECT_AGENTS" -eq 1 ]; then
  AGENT_TARGET_DIRS+=("$PROJECT_AGENTS_DIR")
fi
if [ "$DEPLOY_GLOBAL_AGENTS" -eq 1 ]; then
  AGENT_TARGET_DIRS+=("$GLOBAL_AGENTS_DIR")
fi

EXISTING_API_KEY=""
if [ -f "$AUTH_FILE" ]; then
  EXISTING_API_KEY="$(AUTH_FILE="$AUTH_FILE" python3 - <<'PY'
import json
import os
from pathlib import Path

auth_file = Path(os.environ["AUTH_FILE"])
try:
    data = json.loads(auth_file.read_text())
except Exception:
    data = {}
print(data.get("azure", {}).get("key", ""))
PY
)"
fi

if [ -z "$API_KEY" ]; then
  if [ -n "$EXISTING_API_KEY" ]; then
    if [ -z "$USE_EXISTING_KEY" ]; then
      printf "Existing Azure API key found. Reuse it? [Y/n]: "
      read -r USE_EXISTING_KEY
    fi
    case "${USE_EXISTING_KEY:-Y}" in
      y|Y|yes|YES|"")
        API_KEY="$EXISTING_API_KEY"
        ;;
      n|N|no|NO)
        printf "Azure API key: "
        read -r -s API_KEY
        printf "\n"
        ;;
      *)
        printf "Error: USE_EXISTING_KEY must be y/yes or n/no.\n" >&2
        exit 1
        ;;
    esac
  else
    printf "Azure API key: "
    read -r -s API_KEY
    printf "\n"
  fi
fi

if [ -z "$RESOURCE_NAME" ]; then
  EXISTING_RESOURCE_NAME=""
  for cfg in "${CONFIG_FILES[@]}"; do
    CURRENT_RESOURCE_NAME="$(OPENCODE_CONFIG_FILE="$cfg" python3 - <<'PY'
import json
import os
from pathlib import Path

config_file = Path(os.environ["OPENCODE_CONFIG_FILE"])
try:
    data = json.loads(config_file.read_text())
except Exception:
    data = {}
print(data.get("provider", {}).get("azure", {}).get("options", {}).get("resourceName", ""))
PY
)"
    if [ -n "$CURRENT_RESOURCE_NAME" ]; then
      EXISTING_RESOURCE_NAME="$CURRENT_RESOURCE_NAME"
      break
    fi
  done

  if [ -n "$EXISTING_RESOURCE_NAME" ]; then
    if [ -z "$USE_EXISTING_RESOURCE_NAME" ]; then
      printf "Existing AZURE_RESOURCE_NAME found (%s). Reuse it? [Y/n]: " "$EXISTING_RESOURCE_NAME"
      read -r USE_EXISTING_RESOURCE_NAME
    fi
    case "${USE_EXISTING_RESOURCE_NAME:-Y}" in
      y|Y|yes|YES|"")
        RESOURCE_NAME="$EXISTING_RESOURCE_NAME"
        ;;
      n|N|no|NO)
        printf "AZURE_RESOURCE_NAME: "
        read -r RESOURCE_NAME
        ;;
      *)
        printf "Error: USE_EXISTING_RESOURCE_NAME must be y/yes or n/no.\n" >&2
        exit 1
        ;;
    esac
  else
    printf "AZURE_RESOURCE_NAME: "
    read -r RESOURCE_NAME
  fi
fi

if [ -z "$API_KEY" ] || [ -z "$RESOURCE_NAME" ]; then
  printf "Error: both API key and AZURE_RESOURCE_NAME are required.\n" >&2
  exit 1
fi

for cfg in "${CONFIG_FILES[@]}"; do
  if [ ! -f "$cfg" ]; then
    printf "Error: opencode.json not found at %s\n" "$cfg" >&2
    exit 1
  fi
done

AGENT_FILES=()
if [ "${#AGENT_TARGET_DIRS[@]}" -gt 0 ]; then
  if [ ! -d "$AGENTS_SOURCE_DIR" ]; then
    printf "Error: agents source folder not found at %s\n" "$AGENTS_SOURCE_DIR" >&2
    exit 1
  fi

  AGENT_FILES=("$AGENTS_SOURCE_DIR"/*.md)
  if [ "${#AGENT_FILES[@]}" -eq 0 ] || [ ! -f "${AGENT_FILES[0]}" ]; then
    printf "Error: no agent markdown files found in %s\n" "$AGENTS_SOURCE_DIR" >&2
    exit 1
  fi
fi

mkdir -p "$AUTH_DIR"

API_KEY="$API_KEY" AUTH_FILE="$AUTH_FILE" python3 - <<'PY'
import json
import os
from pathlib import Path

auth_file = Path(os.environ["AUTH_FILE"])
api_key = os.environ["API_KEY"]

data = {}
if auth_file.exists():
    try:
        data = json.loads(auth_file.read_text())
        if not isinstance(data, dict):
            data = {}
    except Exception:
        data = {}

data["azure"] = {"type": "api", "key": api_key}
auth_file.write_text(json.dumps(data, indent=2) + "\n")
PY

for cfg in "${CONFIG_FILES[@]}"; do
RESOURCE_NAME="$RESOURCE_NAME" OPENCODE_CONFIG_FILE="$cfg" python3 - <<'PY'
import json
import os
from pathlib import Path

config_file = Path(os.environ["OPENCODE_CONFIG_FILE"])
resource_name = os.environ["RESOURCE_NAME"]

try:
    data = json.loads(config_file.read_text())
except Exception:
    data = {}

if not isinstance(data, dict):
    data = {}

provider = data.setdefault("provider", {})
azure = provider.setdefault("azure", {})
azure["options"] = {"resourceName": resource_name}

config_file.write_text(json.dumps(data, indent=2) + "\n")
PY
done

for target_dir in "${AGENT_TARGET_DIRS[@]}"; do
  if [ "$target_dir" = "$GLOBAL_AGENTS_DIR" ]; then
    if [ -z "$CLEAN_GLOBAL_AGENTS" ]; then
      printf "Clean existing global agent markdown files before deployment? [y/N]: "
      read -r CLEAN_GLOBAL_AGENTS
    fi
    case "${CLEAN_GLOBAL_AGENTS:-N}" in
      y|Y|yes|YES)
        if [ -d "$target_dir" ]; then
          shopt -s nullglob
          GLOBAL_AGENT_FILES=("$target_dir"/*.md)
          if [ "${#GLOBAL_AGENT_FILES[@]}" -gt 0 ]; then
            rm -f "${GLOBAL_AGENT_FILES[@]}"
          fi
          shopt -u nullglob
        fi
        ;;
      n|N|no|NO|"")
        ;;
      *)
        printf "Error: CLEAN_GLOBAL_AGENTS must be y/yes or n/no.\n" >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$target_dir"
  for legacy_file in "${LEGACY_AGENT_FILES[@]}"; do
    if [ -f "$target_dir/$legacy_file" ]; then
      rm -f "$target_dir/$legacy_file"
    fi
  done
  for src in "${AGENT_FILES[@]}"; do
    cp "$src" "$target_dir/$(basename "$src")"
  done
done

printf "Saved Azure auth to %s and updated Azure provider settings in:\n" "$AUTH_FILE"
for cfg in "${CONFIG_FILES[@]}"; do
  printf -- "- %s\n" "$cfg"
done
if [ "${#AGENT_TARGET_DIRS[@]}" -gt 0 ]; then
  printf "Deployed %s agent files to:\n" "${#AGENT_FILES[@]}"
  for target_dir in "${AGENT_TARGET_DIRS[@]}"; do
    printf -- "- %s\n" "$target_dir"
  done
else
  printf "Skipped agent deployment. Applied auth and Azure provider settings only.\n"
fi
