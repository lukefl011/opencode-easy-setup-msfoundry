---
description: Compatibility alias for legacy executor routing; delegate delivery requests to canonical build agent
mode: subagent
model: azure/premium-mini
temperature: 0
reasoningEffort: low
permission:
  edit: deny
  bash: deny
  task:
    "*": deny
    build: allow
---
- Treat this agent as a deprecated compatibility shim.
- Delegate the full delivery request to `build` without adding or removing steps.
- Preserve approved scope, constraints, and requested report format.
- If delegation is unavailable, direct the caller to use `build` explicitly.
