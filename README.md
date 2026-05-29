# OpenCode Initial Setup

This repository provides a starter setup for OpenCode with MS Foundry, including a preconfigured opencode.json, curated agent definitions, and a setup.sh script to install and configure OpenCode on Linux and macOS.

## What this setup does

- Installs OpenCode if missing (`brew`, `npm`, `bun`, `pnpm`, then `yarn`).
- Writes Azure auth to `~/.local/share/opencode/auth.json`.
- Sets `provider.azure.options.resourceName` in project and/or global `opencode.json` based on selected scope.
- Deploys agent markdown files from `agents/` to project/global agent directories.
- Removes legacy agent files (`pri-*.md` and retired `sub-lg-*.md`) from deployment targets.

## Agent layout

- Primary agents: `ask`, `debug`, `crew-manager`.
- `ask` is agent-level only and does not reference subagents.
- `crew-manager` is the only agent that delegates to subagents.
- Current specialist subagent: `sub-cr-terraform-engineer`.
- All `sub-lg-*` agents are removed.

## How to use `setup.sh`

1. Run `chmod +x ./setup.sh` (one-time, if needed).
2. Run `./setup.sh`.
3. Choose `SCOPE` when prompted: `project`, `global`, or `both`.
4. Enter Azure API key and Azure resource name (or reuse existing values when detected).
5. For global scope, choose whether to copy repo agents to global agents and optionally clean old global `*.md` agent files first.

Non-interactive example:

```bash
SCOPE=both API_KEY=your_key RESOURCE_NAME=your_resource_name ./setup.sh
```

## Settings used by `setup.sh`

- `SCOPE`: `project`, `global`, or `both`.
- `API_KEY`: Azure API key to store in auth file.
- `RESOURCE_NAME`: Azure resource name used in `provider.azure.options.resourceName`.
- `SECRET_VALUE`: fallback source for `RESOURCE_NAME` when `RESOURCE_NAME` is not set.
- `USE_EXISTING_KEY`: `yes|no` reuse behavior when key already exists.
- `USE_EXISTING_RESOURCE_NAME`: `yes|no` reuse behavior when resource name already exists.
- `COPY_REPO_AGENTS_TO_GLOBAL`: `yes|no` controls global agent copy prompt behavior.
- `CLEAN_GLOBAL_AGENTS`: `yes|no` controls whether existing global `*.md` agent files are deleted before copy.

## Files affected

- Auth: `~/.local/share/opencode/auth.json`
- Project config: `./opencode.json`
- Global config: `~/.config/opencode/opencode.json` (or `$XDG_CONFIG_HOME/opencode/opencode.json`)
- Project agents: `./.opencode/agents`
- Global agents: `~/.config/opencode/agents` (or `$XDG_CONFIG_HOME/opencode/agents`)

## Repository layout

- `opencode.json` - OpenCode runtime config and model/provider defaults.
- `agents/` - Agent definitions deployed by `setup.sh`.
- `setup.sh` - Unified setup script for OpenCode + Azure auth/resource configuration.
- `auth.example.json` - Example credential shape for manual auth setup.
