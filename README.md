## High-Volume Payment Processing Platform
Welcome to the root development workspace of the High-Volume Payment Processing Platform. This project is built using a Spec-Driven Development (SDD) model via OpenSpec, enforcing strict decoupling between system behavior, configuration matrices, and actual Java 21 / Spring Boot 3 microservice codebases.
------------------------------
## 1. Multi-Repository Directory Structure
This workspace uses a multi-root architecture mapped via payment-platform.code-workspace. The platform is divided into 12 independent repositories grouped by their operational responsibility:

payment-platform/                  # Root Workspace Directory
├── openspec/                      # Centralized OpenSpec Single Source of Truth
│   ├── config.yaml                # Global module registry & repository mappings
│   ├── project.md                 # Platform Constitution (Clean Architecture & Java Invariants)
│   └── specs/                     # Domain behavioral specs (EARS requirements & GIVEN/WHEN/THEN)
│       ├── api-gateway/spec.md
│       ├── payment-service/spec.md
│       ├── fraud-service/spec.md
│       ├── payment-worker/spec.md
│       ├── provider-router-service/spec.md
│       ├── ledger-service/spec.md
│       ├── reconciliation-service/spec.md
│       ├── shared-contracts/spec.md
│       ├── notification-service/spec.md
│       ├── analytics-service/spec.md
│       ├── payment-infrastructure/spec.md
│       └── payment-ui/spec.md
│
├── payment-api-gateway/           # Edge routing, OAuth validation, Rate limiting repository
├── payment-ui/                    # React + TypeScript administrative dashboard repository
├── payment-service/               # State machine orchestrator & Idempotency manager repository
├── fraud-service/                 # Non-blocking transaction risk scoring engine repository
├── payment-worker/                # Asynchronous high-throughput transaction consumer repository
├── provider-router-service/       # Dynamic third-party gateway strategy router repository
├── notification-service/          # Outbound customer alerting (SMS, Email, Push) repository
├── ledger-service/                # Write-once, append-only transaction ledger repository
├── reconciliation-service/        # Post-facto clearing processing & anomaly recovery repository
├── analytics-service/             # Read-optimized business metrics dashboard engine repository
├── shared-contracts/              # Centralized schema models & Protocol Buffers repository
└── payment-infrastructure/        # Infrastructure-as-Code (Terraform/Bicep modules) repository

------------------------------
## 2. Architectural Summary of Completed Milestones
The platform's structural design has been fully detailed across the following sequential execution steps:

   1. Workspace Configuration (payment-platform.code-workspace): Configured the IDE workspace to manage 12 isolated repositories concurrently while setting up strict search exclusions for transient compilation targets (/bin, /obj, /node_modules).
   2. Platform Constitution (openspec/project.md): Set the non-negotiable architectural ground rules for all developers, mandating Clean Architecture patterns, Java 21+ idioms, stateless Spring components, database portability between SQL Server and Oracle, and the Transactional Outbox pattern.
   3. Global Workspace Index (openspec/config.yaml): Registered all modules and their spec targets to allow AI agents and continuous integration compliance pipelines to map code modifications to specific behavioral invariants.
   4. API Gateway (specs/api-gateway/spec.md): Established edge perimeter policies, enforcing distributed tracing injections (X-Correlation-ID), mandatory client-side idempotency keys, and edge token bucket rate-limiting.
   5. Core Lifecycle (specs/payment-service/spec.md): Configured the closed, deterministic finite state machine handling transaction steps and unit-of-work abstractions.
   6. Risk Analysis (specs/fraud-service/spec.md): Built non-blocking rule evaluation hooks designed to score transactions asynchronously before payment orchestration workers capture funds.
   7. Execution Worker (specs/payment-worker/spec.md): Engineered high-throughput, idempotent Kafka event stream consumers with explicit back-off mechanics and Dead Letter Queue (DLQ) isolation.
   8. Provider Routing (specs/provider-router-service/spec.md): Developed a dynamic strategy locator factory pattern to cleanly abstract vendor API payloads, credentials, and failover states.
   9. Financial Audit Core (specs/ledger-service/spec.md): Instituted absolute, double-entry, write-once immutable bookkeeping invariants preventing direct row updates or deletions.
   10. Reconciliation Frame (specs/reconciliation-service/spec.md): Implemented post-facto asynchronous batch clearing processors that trace and report variances between internal data and external statements.
   11. Shared Contracts Schema (specs/shared-contracts/spec.md): Defined backward-compatibility requirements for decoupled serialization layers to prevent independent deployments from causing cross-cluster schema drift.
   12. Customer Notification Ring (specs/notification-service/spec.md): Isolated multi-channel dispatch frameworks (Email, SMS, Push) from core transactional domains via stateless, message-driven loops.
   13. Telemetry Analytics (specs/analytics-service/spec.md): Constructed an asynchronous read-model database projection framework using CQRS principles to keep long-running calculation queries off transactional resources.
   14. Infrastructure-as-Code (specs/payment-infrastructure/spec.md): Bound environment creation to parameter-driven declarative scripts (Terraform/Bicep) with automated secure secret vault injection.
   15. User Interface Canvas (specs/payment-ui/spec.md): Standardized a React + TypeScript SPA boundary designed to react to backend REST error structures, inject client-side idempotency tracking markers, and handle sensitive cardholder profiles inside secure iframes.

------------------------------
## 3. Local Development Execution Loop
When building out codebases within any individual repository, adhere to the single source of truth:

* Run openspec validation (or your pipeline's lint command) to guarantee local implementations do not violate the core requirements written in the openspec/specs/ directory.
* Ensure all code modifications preserve the separation of concerns between API, Application, Domain, and Infrastructure modules defined in the platform constitution.

------------------------------
## 4. Rationale and Strategic Sequencing Breakdown
In high-volume distributed microservices architectures and Spec-Driven Development (SDD), the order of operations is vital to prevent circular engineering redesign loops and architectural drift. The platform's specifications were built according to the following engineering phases:
## Phase 1: Structural Foundations & Constraining Invariants (Steps 1–3)

* The Strategy: Establish the workspace settings, global configurations, and platform constitution prior to initializing functional code parameters. In a distributed 12-repository framework, this prevents development teams from introducing conflicting structural paradigms or language versions.
* The Rationale: Locking the Constitution first initializes an architectural "gravity well." Every subsequent sub-service specification file automatically inherits these core invariants (such as Clean Architecture boundaries, Java 21 thread parameters, and database portability), ensuring absolute uniformity before any feature workflows are detailed.

## Phase 2: Request Entry & Core State Control (Steps 4–6)

* The Strategy: Trace and map the direct, synchronous line-of-sight journey of an inbound payment. This maps data precisely from the absolute edge parameter layer (Gateway routing/throttling) directly into the primary transactional engine (State Machine), followed by its immediate prerequisite validation check (Fraud Risk Evaluation).
* The Rationale: This sequencing defines the system's core transactional domain and state boundaries. We explicitly enforce how data enters the ecosystem and how its lifecycle state is managed before designing any asynchronous background daemons.

## Phase 3: High-Throughput Async Execution & Integration (Steps 7–8)

* The Strategy: Isolate long-running downstream network calls from the primary API request loops. The core lifecycle engine offloads complex execution states asynchronously to high-performance workers via messaging partitions. The worker then delegates explicit provider mappings to a decoupled routing framework.
* The Rationale: Specifying the Payment Worker and Provider Router immediately following the state engine allows the architecture to solidify its asynchronous handoff protocols (such as Kafka consumer loops, retry topologies, and strategy factories) while lifecycle state logic is fresh.

## Phase 4: Financial Integrity & Asset Accounting (Steps 9–10)

* The Strategy: Record and auditing the resulting transactional mutations securely. Once an integration strategy resolves a provider response, the outcome becomes formal financial record data. It must be appended immutably to a corporate journal (Ledger) and cross-checked against external settlement assets (Reconciliation).
* The Rationale: Positioning the ledger and reconciliation components here completes the functional transaction stream loop, ensuring total data auditability from edge entry to settling files.

## Phase 5: Shared Contracts & Downstream Utilities (Steps 11–13)

* The Strategy: Abstract the settled domain patterns into reusable network contract libraries. Once core processing engines, workers, and ledger persistence schemas are validated, their shared messaging payloads are centralized into a versioned registry (shared-contracts). This creates the foundation for decoupled, reactive notification and analytics systems.
* The Rationale: Because notifications and telemetry engines are pure downstream consumers of system data, designing them earlier would have resulted in unvalidated schema assumptions and pipeline breakage during structural changes.

## Phase 6: Cloud Provisioning & Visual Consumption (Steps 14–15)

* The Strategy: Construct the surrounding environmental and client layers around the backend architecture. Infrastructure-as-Code modules build the physical cloud topologies (subnets, AKS clusters, secret vaults) matching the service map. The frontend interface serves as the final consumption plane.
* The Rationale: Designing infrastructure rules and user experiences last ensures they match your backend constraints perfectly. Because the UI layer has visibility over gateway error contracts (e.g., HTTP 429), state structures, and pagination signatures, it can be engineered cleanly without guessing api specifications.


