# Context Profile: Terraform Azure

Use this profile for Terraform modules and Azure infrastructure delivery.

## Objectives

- maintain idempotent, reviewable infrastructure as code
- protect production safety with explicit drift and blast-radius analysis
- keep Azure environment boundaries and module ownership clear

## Planning expectations

- include resource impact map by subscription, resource group, and environment
- include state backend, locking, and workspace strategy implications
- include identity, RBAC, secrets, and policy/compliance considerations
- include plan/apply validation strategy plus rollback path

## Build/check expectations

- terraform fmt and terraform validate across changed modules
- terraform plan for impacted environments with clear diff summary

## Release expectations

- remote state and backend access readiness verified
- approval gates and change window confirmed
- post-apply verification, monitoring, and alert checks defined
- rollback or forward-fix runbook documented
