# Initiative Plan State

## Initiative

Rename primary agents by removing only the `pri-` prefix.

### Constraint

Do not keep dual old/new entries in menu or operator-facing command lists (for example, `plan` + `pri-plan` must not both appear).

## State

- Status: in_progress
- Owner: OpenCode maintainers
- Last updated: 2026-04-25
- Execution monitor: `docs/initiative-plan-state.md`

## Durable Task Table

| ID  | Task | Status | Owner | Done Criteria |
| --- | ---- | ------ | ----- | ------------- |
| T01 | Contract & impact inventory | completed | sub-lg-analysis | Inventory approved; all primary `pri-*` rename targets and impacted references identified, including menu/command surfaces. |
| T02 | Rename primary files/internal refs | completed | plan, build, ask, debug owners | Primary agent filenames and internal references updated to no-prefix names; no stale `pri-` usage in primary contract definitions. |
| T03 | Update runtime config & non-primary references | completed | sub-lg-builder + sub-lg-crew-manager | Runtime config, dispatch routing, docs indexes, and non-primary references point to renamed primary agents with no duplicate old/new menu entries. |
| T04 | Add setup migration cleanup for stale pri-* files | completed | sub-cr-terraform-engineer | Setup/migration path removes or archives stale `pri-*` primary files safely and idempotently. |
| T05 | Update README/operator migration notes | completed | sub-lg-plan-reviewer + sub-lg-release | README and operator migration notes document renamed commands, rollout steps, and explicitly state no dual menu entries. |
| T06 | Validation + release gate | pending | sub-lg-qa + build gatekeeper | Validation suite passes (rename integrity, menu uniqueness, migration behavior) and release checklist signed off. |

## Dependencies

### Critical Path

T01 (completed) → T02 → T03 → T04 → T05 → T06

### Parallel Groups

- **Group A (can overlap after T02 starts):**
  - T03 Update runtime config & non-primary references
  - T05 Update README/operator migration notes (drafting can begin early; finalization depends on T03/T04 outcomes)
- **Group B (after T03 baseline available):**
  - T04 Add setup migration cleanup for stale `pri-*` files
- **Group C (final gate):**
  - T06 Validation + release gate (after T02-T05 completion)

## Validation Gates

1. **Naming Gate**
   - Primary agent files exist only under no-prefix names (`plan`, `build`, `ask`, `debug`).
   - No required primary runtime path depends on old `pri-*` names.
2. **Menu/Command Uniqueness Gate**
   - Operator/menu surfaces do not show dual entries such as `plan` + `pri-plan`.
   - Exactly one canonical command per renamed primary agent.
3. **Migration Gate**
   - Setup/migration cleanup handles stale `pri-*` artifacts safely.
   - Re-running migration is idempotent and does not break fresh installs.
4. **Documentation Gate**
   - README and migration notes reflect final naming and rollout guidance.
5. **Release Gate**
   - Validation evidence attached and T06 marked completed.

## Risk Register

| Risk ID | Description | Impact | Likelihood | Mitigation | Owner | Status |
| ------- | ----------- | ------ | ---------- | ---------- | ----- | ------ |
| R01 | Dual command/menu entries accidentally retained (`pri-*` + new names). | High | Medium | Add explicit uniqueness checks in T03/T06; review all surfaced command lists. | sub-lg-qa | open |
| R02 | Hidden internal references to `pri-*` break runtime dispatch. | High | Medium | Comprehensive search + contract checks in T02/T03; validation gate before release. | sub-lg-builder | open |
| R03 | Migration cleanup removes wrong files or is non-idempotent. | High | Low-Medium | Implement guarded cleanup rules and rerun tests in T04/T06. | sub-cr-terraform-engineer | open |
| R04 | Operator confusion during transition. | Medium | Medium | Clear README/migration notes with before/after mappings in T05. | sub-lg-release | open |

## Append-Only Execution Log

| Date (UTC) | Entry |
| ---------- | ----- |
| 2026-04-25 | Planning state initialized for initiative "Rename primary agents by removing only the `pri-` prefix". Task table, dependencies, validation gates, risks, and initial statuses recorded; T01 marked completed, T02-T06 pending. |
| 2026-04-25 | T02-T05 moved to `in_progress` and completed in one implementation pass: primary files renamed to `ask/plan/build/debug`, active references updated, runtime default agent switched to `build`, and setup migration now removes stale `pri-*.md` primary files in project/global deployment targets while preserving unrelated files. |
