# Context Profiles

This repository is context-driven. Instead of hardcoding one domain, agent behavior and workflows follow the active profile.

## How context is selected

- `contexts/active.md` is the source of truth for current context.
- Use `/context-show` to inspect current context behavior.
- Use `/context-use <general|backend|mobile|web|terraform-azure>` to switch context.

## Design principle

- Core agents are domain-neutral (`planner`, `debugger`, `builder`, `qa`, `release`).
- Domain-specific behavior comes from active context rules.
- Context files are reusable across repositories; application code is optional.
