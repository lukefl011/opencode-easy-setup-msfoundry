#!/usr/bin/env bash
set -euo pipefail

AUTH_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode"
AUTH_FILE="$AUTH_DIR/auth.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_CONFIG_FILE="$SCRIPT_DIR/opencode.json"
GLOBAL_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
GLOBAL_CONFIG_FILE="$GLOBAL_CONFIG_DIR/opencode.json"

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

ensure_opencode

if [ -z "$SCOPE" ]; then
  printf "Setup scope [project/global] (default: project): "
  read -r SCOPE
fi

SCOPE="${SCOPE:-project}"

case "$SCOPE" in
  project)
    OPENCODE_CONFIG_FILE="$PROJECT_CONFIG_FILE"
    ;;
  global)
    mkdir -p "$GLOBAL_CONFIG_DIR"
    OPENCODE_CONFIG_FILE="$GLOBAL_CONFIG_FILE"
    if [ ! -f "$OPENCODE_CONFIG_FILE" ]; then
      printf '{}\n' > "$OPENCODE_CONFIG_FILE"
    fi
    ;;
  *)
    printf "Error: SCOPE must be 'project' or 'global'.\n" >&2
    exit 1
    ;;
esac

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
  printf "AZURE_RESOURCE_NAME: "
  read -r RESOURCE_NAME
fi

if [ -z "$API_KEY" ] || [ -z "$RESOURCE_NAME" ]; then
  printf "Error: both API key and AZURE_RESOURCE_NAME are required.\n" >&2
  exit 1
fi

if [ ! -f "$OPENCODE_CONFIG_FILE" ]; then
  printf "Error: opencode.json not found at %s\n" "$OPENCODE_CONFIG_FILE" >&2
  exit 1
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

RESOURCE_NAME="$RESOURCE_NAME" OPENCODE_CONFIG_FILE="$OPENCODE_CONFIG_FILE" python3 - <<'PY'
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
options = azure.setdefault("options", {})
options["resourceName"] = resource_name

config_file.write_text(json.dumps(data, indent=2) + "\n")
PY

printf "Saved Azure auth to %s and updated %s.\n" "$AUTH_FILE" "$OPENCODE_CONFIG_FILE"
