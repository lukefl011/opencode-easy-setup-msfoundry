# Active Context

## Profile

- `name`: general
- `source`: contexts/general.md

## Conventions

- Prioritize reusable, maintainable implementation choices.
- Keep changes scoped and easy to verify.
- Document risky assumptions and migration concerns.

## Command matrix

- `build-check`: run project-standard lint/typecheck/test commands in the target repository
- `release-check`: verify build, changelog, versioning, env completeness, rollback plan

## Risk checklist

- breaking changes clearly identified
- data migration or schema impact assessed
- test coverage updated for changed behavior
- release notes and rollback path prepared
