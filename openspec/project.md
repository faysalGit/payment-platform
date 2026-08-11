# High-Volume Payment Processing Platform: Constitution

## 1. System Ecosystem & Tech Stack
The platform is built as a production-grade, highly scalable distributed microservices architecture using Java 21+ and Spring Boot 3.x. The global system constraints are enforced as follows:

*   **Runtime Environment**: Java 21 (LTS) with Spring Boot 3.x.
*   **Architecture Pattern**: Clean Architecture (Domain, Application, Infrastructure, API Layers).
*   **Asynchronous Messaging**: Apache Kafka utilizing Spring-Kafka abstractions for high-throughput orchestration.
*   **Database Portability**: Dynamic persistence abstraction supporting interchangeable Microsoft SQL Server and Oracle Database instances.
*   **API Documentation**: RESTful interfaces exposed via OpenAPI v3 JSON specs with Scalar interactive frontends (`/scalar`).
*   **Container Ingress & Deployment**: Dockerized microservices deployed on Azure Kubernetes Service (AKS) through managed Azure DevOps CI/CD pipelines.

## 2. Multi-Repository Workspace Topology
The system is partitioned into 12 independent source repositories, grouped by logical domain boundaries. Each repository must remain operational, testable, and deployable without relying on synchronous runtime dependencies from peer repositories.

```text
payment-platform/ (Root Directory)
├── payment-api-gateway/          # Edge routing, OAuth validation, Rate limiting
├── payment-ui/                   # React + TypeScript administrative interface
├── payment-service/              # State machine orchestrator & Idempotency manager
├── fraud-service/                # Non-blocking transaction risk scoring engine
├── payment-worker/               # Asynchronous high-throughput transaction consumer
├── provider-router-service/      # Dynamic third-party gateway strategy router
├── notification-service/         # Outbound customer alerting (SMS, Email, Push)
├── ledger-service/               # Write-once, append-only transaction ledger
├── reconciliation-service/       # Post-facto clearing processing & anomaly recovery
├── analytics-service/            # Read-optimized business metrics dashboard engine
├── shared-contracts/             # Centralized schema models, Protocol Buffers & common contracts
└── payment-infrastructure/       # Multi-environment infrastructure-as-code (Terraform/Bicep)
```

## 3. Clean Architecture Layers for Java
Every Java backend service repository MUST isolate business logic from infrastructure frameworks. Codebases must strictly follow these structural layer constraints:

### 3.1 Domain Layer
*   **Contents**: Pure Java POJOs capturing domain aggregates, entities, value objects, pure domain exceptions, and abstract core interface definitions.
*   **Constraints**: Absolute isolation. The domain layer MUST NOT import or reference external libraries (including Spring Framework, Jackson, Jakarta Persistence/JPA, or Apache Kafka).

### 3.2 Application Layer
*   **Contents**: Command and Query use cases, validation components, application-specific DTO projections, and service port interfaces.
*   **Constraints**: Orchestrates workflow logic based on domain abstractions. It depends only on the Domain Layer or its own internal abstractions.

### 3.3 Infrastructure Layer
*   **Contents**: Spring Data JPA repositories, Kafka configurations, external payment provider clients, encryption adapters, and logging framework integrations.
*   **Constraints**: Contains all technical implementations. Changes here must never bleed into or break the application or domain layers.

### 3.4 API Layer
*   **Contents**: RestControllers, OpenAPI configurations, exception handling advice beans, Spring Security configuration classes, and validation filters.

## 4. Engineering & Concurrency Invariants

### 4.1 Dependency Injection & Code Quality
*   **Constructor Injection**: All components MUST use constructor-based dependency injection. Field injection (`@Autowired` on variables) is strictly prohibited to keep modules loosely coupled and testable.
*   **SOLID Compliance**: Classes must satisfy the Single Responsibility Principle, and runtime configuration switches must utilize polymorphic extensions via the Strategy or Factory design patterns rather than standard conditional if/else evaluation chains.

### 4.2 Non-Blocking Asynchronous Operations
*   **Java Asynchrony**: All network, database, and system I/O pipeline handshakes MUST utilize non-blocking asynchronous APIs. Java `CompletableFuture`, Spring `@Async` threads, or reactive streams should be preferred.
*   **Blocking Prohibition**: Process-blocking execution methods such as `.get()`, `.join()`, or raw `Thread.sleep()` are structurally forbidden within normal processing loops.

### 4.3 Thread Safety & Stateless Contexts
*   **Stateless Component Design**: All Spring beans registered with standard `@Component`, `@Service`, or `@Repository` annotations must remain entirely stateless. Request-scoped mutations must never be written to singleton fields.
*   **Concurrent Resource Management**: High-volume stream consumers running concurrent jobs must establish optimistic locking concurrency strategies, unique database index attributes, or explicit event tokens to enforce state integrity instead of using raw Java process-level `synchronized` markers or locks.

## 5. Persistence, State, & Data Portability

### 5.1 Abstract Database Portability
*   Application use cases must access persistent records exclusively through decoupled repository interfaces.
*   Direct implementation leaks—such as writing vendor-specific SQL scripts (T-SQL or PL/SQL) inside the application boundary or relying on provider-specific JPA dialects—are prohibited.
*   The persistence abstraction layer must guarantee seamless database portability between Microsoft SQL Server and Oracle Database without requiring rewrites of domain rules.

### 5.2 Transactional Continuity (Unit of Work)
*   Atomic batch updates targeting multiple repository state changes MUST execute within an explicitly bounded database transaction framework (using `@Transactional` boundary definitions or a structural Unit of Work manager interface).
*   Data aggregate mutations and their resulting transaction audit history entries or outbox events must succeed or roll back together as one atomic unit.

### 5.3 Idempotency Framework
*   The entry point of the payment lifecycle execution pipeline MUST intercept requests using a standardized tracking structure.
*   The checking module must validate incoming tracking tokens against a dedicated Idempotency Repository before releasing execution flow to downstream business use cases.

### 5.4 Transactional Outbox Pattern
*   To guarantee consistency between the database and Apache Kafka without introducing distributed 2PC transactions, services mutating operational models MUST write outbox notification records into an internal transaction database table within the same transaction scope.
*   An independent asynchronous publisher thread or Change Data Capture (CDC) engine shall stream those outbox entries into the respective Kafka topic lines.

## 6. Testing Strategy Matrix
Every independent Java microservice repository is required to run automated testing architectures isolated within its own boundaries:

*   **Unit Tests**: Standard JUnit 5 and Mockito suites verifying state machines, validation rules, strategy locators, and pure application handling workflows. Infrastructure dependencies must be fully mocked out using interfaces.
*   **Integration Tests**: Validates repository connectivity, Spring Data query performance, Kafka transport loops, and transactional boundary rollbacks via containerized runtimes (e.g., Testcontainers for SQL Server/Oracle/Kafka).
*   **Contract Tests**: Structural contract consistency checking between microservice boundaries using tools like Pact to verify message and API structure compliance.
*   **End-to-End Tests**: Automated deployment testing checking the complete abstract processing lifecycle across boundaries (Creation -> Risk Scoring -> Routing Strategy -> Ledger Handoff) under simulated environments.
