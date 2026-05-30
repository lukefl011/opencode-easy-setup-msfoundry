# OpenCode Linux/macOS Easy Setup with MS Foundry

This repository provides a starter setup for OpenCode with MS Foundry, including a preconfigured opencode.json, curated agent definitions, and a setup.sh script to install and configure OpenCode on Linux and macOS.

## What this setup does

- Installs OpenCode if missing ('https://opencode.ai/download'). 
- Writes Azure auth to `~/.local/share/opencode/auth.json`.
- Sets `provider.azure.options.resourceName` in project and/or global `opencode.json` based on selected scope.
- Deploys agent markdown files from `agents/` to project/global agent directories.


## Agent layout

- Primary agents: `ask`, `crew-manager`.
- `ask` is agent-level only and does not reference subagents.
- `crew-manager` is the only agent that delegates to subagents.
- Specialist subagents: `sub-cr-terraform-engineer`, `sub-cr-mobile-app-developer`.

### When to use specialist subagents

- Use `sub-cr-terraform-engineer` for Terraform/IaC planning, risk controls, validation criteria, and rollout sequencing.
- Use `sub-cr-mobile-app-developer` for mobile app architecture, open-source stack choices, UI/UX quality principles, and delivery/testing plans.


## How to use `setup.sh`

1. Run `chmod +x ./setup.sh` (one-time, if needed).
2. Run `./setup.sh`.
3. Choose `SCOPE` when prompted: `project` or `global`.
4. If `SCOPE=project`, enter `/path/to/target-repo` when prompted (or pass it as arg/env var).
5. Enter Azure API key and Azure resource name (or reuse existing values when detected).
6. For global scope, choose whether to copy repo agents to global agents and optionally clean old global `*.md` agent files first.

Notes:

- `target-repo-path` is required only for `SCOPE=project`; global setup does not need it.
- You can pass target repository path as arg (`./setup.sh /path/to/target-repo`) or with `TARGET_REPO_PATH`.
- For project scope, target path must be a git repository and cannot be this setup repository itself.

Non-interactive example:

```bash
SCOPE=project API_KEY=your_key RESOURCE_NAME=your_resource_name ./setup.sh ~/code/my-app

# or
SCOPE=project TARGET_REPO_PATH=~/code/my-app API_KEY=your_key RESOURCE_NAME=your_resource_name ./setup.sh
```

## Settings used by `setup.sh`

- Positional arg 1 (optional): target repository path used when `SCOPE=project`.
- `TARGET_REPO_PATH`: optional alternative source for project target repository path.
- `SCOPE`: `project` or `global`.
- `API_KEY`: Azure API key to store in auth file.
- `RESOURCE_NAME`: Azure resource name used in `provider.azure.options.resourceName`.
- `SECRET_VALUE`: fallback source for `RESOURCE_NAME` when `RESOURCE_NAME` is not set.
- `USE_EXISTING_KEY`: `yes|no` reuse behavior when key already exists.
- `USE_EXISTING_RESOURCE_NAME`: `yes|no` reuse behavior when resource name already exists.
- `COPY_REPO_AGENTS_TO_GLOBAL`: `yes|no` controls global agent copy prompt behavior.
- `CLEAN_GLOBAL_AGENTS`: `yes|no` controls whether existing global `*.md` agent files are deleted before copy.

## Files affected

- Auth: `~/.local/share/opencode/auth.json`
- Project config: `<target-repo>/opencode.json`
- Global config: `~/.config/opencode/opencode.json` (or `$XDG_CONFIG_HOME/opencode/opencode.json`)
- Project agents: `<target-repo>/.opencode/agents`
- Global agents: `~/.config/opencode/agents` (or `$XDG_CONFIG_HOME/opencode/agents`)
