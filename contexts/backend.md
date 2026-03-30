# Context Profile: Backend

Use this profile for service, API, worker, and data tasks.

## Objectives

- preserve service reliability and data integrity
- maintain clear contracts and observability
- minimize production risk from schema or infra changes

## Planning expectations

- include endpoint/contract impact
- include schema migration impact and rollback
- include performance and security implications
- include test plan (unit/integration/smoke)

## Build/check expectations

- lint, typecheck, tests
- integration checks where available

## Release expectations

- migration plan and rollback path
- config/env completeness
- alerting and dashboard readiness
- runbook updates for incidents
