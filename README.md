# OpenCode Project Setup

This repository configures a context-driven OpenCode workspace with specialized agents, reusable context profiles, and built-in slash commands for planning, debugging, validation, and release checks.

## Agents

Primary agents are defined in `opencode.json`:

- `ask` - Read-only Q&A agent for repository and technical explanation tasks.
- `build` - Default implementation agent with code edit/build authority.
- `plan` - Read-first planning/risk analysis agent with guarded edit/bash permissions.

The default agent is `build`.

## Subagents (Task Delegation)

The `build` and `plan` flows can delegate to domain-neutral subagents:

- `planner` - Creates phased implementation plans.
- `plan-reviewer` - Critically reviews draft plans.
- `debugger` - Performs issue triage and root-cause analysis.
- `builder` - Supports implementation execution.
- `qa` - Focuses on validation and quality checks.
- `release` - Evaluates release readiness and rollback posture.

## Context Profiles

Context rules live in `contexts/` and control expectations for planning, checks, and release readiness.

Available profiles:

- `general`
- `backend`
- `mobile`
- `web`
- `terraform-azure`

The active profile is tracked in `contexts/active.md`.

## How To Start

1. Clone this repo and open it in your terminal.
2. Ensure OpenCode CLI is installed and authenticated for your Azure provider setup.
3. Set secrets before launch (for both global and project runs):
   - copy `.secrets.example` to `.secrets`
   - export variables from `.secrets` in your shell (or load them with your shell profile)
4. Start OpenCode in this directory.
5. Run `/context-show` to confirm the active context.
6. (Optional) Switch context with `/context-use <profile>`.

## How To Use

Use the built-in commands from `opencode.json`:

- `/ask-repo <question>` - Ask read-only repository questions.
- `/context-show` - Show active context behavior.
- `/context-use <general|backend|mobile|web|terraform-azure>` - Switch active context.
- `/plan-task <task>` - Generate a context-aware implementation plan.
- `/review-plan <draft plan>` - Critically review an implementation plan.
- `/debug-task <issue>` - Triage and rank likely root causes.
- `/build-check` - Run profile-aware lint/typecheck/test checks.
- `/release-check` - Run profile-aware release readiness checks.

Legacy aliases:

- `/plan-feature <task>` - Alias of `/plan-task`.
- `/debug-bug <issue>` - Alias of `/debug-task`.

## Repository Layout

- `opencode.json` - Agent, model, permission, and slash-command configuration.
- `contexts/` - Domain context profiles and active profile metadata.
- `.secrets.example` - Template for local secret values.

## Notes

- Keep `contexts/active.md` as the single source of truth for current behavior.
- Add new profiles under `contexts/` and update command templates only when behavior truly differs by domain.
- Shared model/provider defaults live in `~/.config/opencode/opencode.jsonc`; repository-specific agent/command behavior stays in project `opencode.json`.
