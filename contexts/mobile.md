# Context Profile: Mobile

Use this profile for building and maintaining production-grade React Native applications with Expo.

## Scope

- Cross-platform mobile applications targeting iOS and Android.
- Shared business logic with platform-specific adapters when needed.
- Feature delivery that balances speed, UX quality, and operational reliability.

## Objectives

- Maintain iOS and Android parity for core user journeys.
- Preserve UX quality, performance, and reliability under real device constraints.
- Keep mobile module boundaries clean and platform-specific concerns isolated.
- Ensure release and runtime behavior is observable, testable, and reversible.

## Recommended technology stack

- Runtime/framework: Expo (managed workflow) + React Native + TypeScript.
- Backend for local development: run the client-connected server via Docker/Docker Compose for parity and reproducibility.
- Navigation: React Navigation with typed route params.
- Server state: TanStack Query (React Query) for caching, retries, and request lifecycle.
- Local state: Zustand (or lightweight context) for UI/session state; avoid global overuse.
- Forms and validation: React Hook Form + Zod schemas.
- Networking: Centralized API client layer with typed request/response contracts.
- Testing: Jest + React Native Testing Library + Detox for smoke e2e.
- Observability: Sentry (errors/perf), structured logs, and product analytics events.
- Delivery: EAS Build + EAS Submit + EAS Update with explicit channels.

## Dev environment contract

- Use `docker compose up` as the default way to start backend dependencies used by the mobile client.
- Keep API base URL configurable via environment variables (for example, `EXPO_PUBLIC_API_URL`).
- Define and document stable local ports (for example, API `:8080`, DB `:5432`) to avoid team drift.
- Keep a versioned compose file in the server repo and include a minimal healthcheck for app startup readiness.
- Maintain `.env.example` for client and server with required keys and safe placeholder values.

## Best practices

- Keep architecture feature-first: co-locate screens, hooks, tests, and feature state.
- Separate domain logic from UI components; keep side effects in hooks/services.
- Prefer typed interfaces end-to-end; avoid `any` in API and navigation boundaries.
- Handle offline/slow-network states explicitly (loading, retry, empty, stale, error).
- Define design tokens (spacing, typography, color, radius) and reuse consistently.
- Optimize rendering: stable keys, memoization where needed, avoid unnecessary re-renders.
- Treat accessibility as default: labels, roles, touch targets, dynamic font scaling, contrast.
- Protect secrets and environment config; never hardcode credentials in client code.
- Standardize local API dependencies in containers; avoid ad-hoc host-only backend setups.
- Add telemetry for critical flows (auth, checkout, sync) with actionable error context.
- Keep migrations and SDK upgrades incremental; document risk and rollback path.

## Planning expectations

- include platform impact (iOS/Android)
- include feature/module impact map
- include API contract impact
- include unit/component/e2e smoke strategy
- include analytics/monitoring impact for critical paths
- include rollout and rollback strategy (store release and OTA update)

## Build/check expectations

- lint, typecheck, unit tests, component tests
- mobile smoke checks for critical flows
- no TypeScript errors and no unresolved runtime warnings in changed flows
- verify startup time, navigation responsiveness, and error handling in impacted screens

## Release expectations

- EAS profile and channel validation
- app version/build number alignment
- signing and env readiness
- rollback and incident response plan
- release notes include user-facing changes, flags, and known limitations
