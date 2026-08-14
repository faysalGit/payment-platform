# Global Architecture Blueprint & Platform System Manual
## Platform System Manual & Core Engineering Specifications
------------------------------
## 1. Global Master Architecture Diagram & Component Topology
```

                                  +---------------------------------------+
                                  |         PAYMENT-UI PORTAL             |
                                  |     (React + TypeScript SPAs)         |
                                  +---------------------------------------+
                                                      |
                                          HTTPS (OAuth2 JWT Tokens)
                                                      v
                                  +---------------------------------------+
                                  |         PAYMENT-API-GATEWAY           |
                                  |     (Spring Cloud Perimeter Node)     |
                                  +---------------------------------------+
                                                      |
                                           Internal Sync HTTP REST
                                                      v
                                  +---------------------------------------+
                                  |            PAYMENT-SERVICE            |
                                  |    (Ingestion Core / Clean Arch)      |
                                  +---------------------------------------+
                                                      |
                                   Publishes [PaymentCreatedEvent]
                                                      v
                                  =========================================
                                  |     KAFKA TOPIC: [payment-events]     |
                                  =========================================
                                                      |
                                          Asynchronous Ingestion
                                                      v
                                  +---------------------------------------+
                                  |             FRAUD-SERVICE             |
                                  |    (Asynchronous Risk Evaluation)     |
                                  +---------------------------------------+
                                                      |
                                   Publishes [FraudEvaluatedEvent]
                                                      v
                                  =========================================
                                  |      KAFKA TOPIC: [fraud-events]      |
                                  =========================================
                                                      |
                                          Asynchronous Ingestion
                                                      v
                                  +---------------------------------------+
                                  |            PAYMENT-WORKER             |
                                  |    (State Engine / Redis Lock Core)   |
                                  +---------------------------------------+
                                                      |
                                         Non-Blocking Async HTTP REST
                                                      v
                                  +---------------------------------------+
                                  |        PROVIDER-ROUTER-SERVICE        |
                                  |  (Stateless Banking Gateway Selector) |
                                  +---------------------------------------+
                                                      |
                                         Outbound WebClient Connection
                                                      v
                                  +---------------------------------------+
                                  |     EXTERNAL CREDIT CARD NETWORKS     |
                                  |           (Stripe / Adyen)            |
                                  +---------------------------------------+
                                                      |
                                         Returns Processing Outcome
                                                      v
                                  +---------------------------------------+
                                  |            PAYMENT-WORKER             |
                                  | (Saves Outcome & Commits Kafka Offset)|
                                  +---------------------------------------+
                                                      |
                                    Publishes Terminal Clearing Events
                                                      v
                                  =========================================
                                  |   KAFKA TOPICS:                       |
                                  |   [payment-succeeded]/[payment-failed]|
                                  =========================================
                                   /                  |                  \
                                  /                   |                   \
                                 v                    v                    v
                  +---------------------+   +---------------------+   +---------------------+
                  | NOTIFICATION-SERVICE|   |   LEDGER-SERVICE    |   |RECONCILIATION-SRVC  |
                  |(Async Customer Alert)   |(Immutable Bookkeeper)   |(Audit Balancing Core)
                  +---------------------+   +---------------------+   +---------------------+

=====================================================================================================
                                   OPERATIONAL SUPPORT CORES
=====================================================================================================
     +-----------------------------------+       +-----------------------------------+
     |       SHARED-CONTRACTS JAR        |       |      PAYMENT-INFRASTRUCTURE       |
     | (Immutable DTO & Event Classpath) |       |  (Orchestrator Hub / Compose / Pre)|
     +-----------------------------------+       +-----------------------------------+
```
------------------------------
## 2. Comprehensive Global Repository Matrix
The complete platform architecture spans 12 distinct, fully decoupled source code repositories organized within a global workspace structure:

```
## Repository Architecture
-------------------------

## shared-contracts

- **Port:** N/A
- **Architecture:** Cross-Cutting Domain Model
- **Technical Stack:** Java 21 Records, Jackson Datatypes
- **Responsibility:** Maintains shared DTOs, immutable event schemas, common domain models, and Kafka contracts used across all microservices.
-------------------------

## payment-api-gateway

- **Port:** 8080
- **Architecture:** External Perimeter Edge Node
- **Technical Stack:** Spring Cloud Gateway, Netty Reactive
- **Responsibility:** Handles request routing, OAuth2/JWT authentication, SSL termination, API versioning, and rate limiting.
-------------------------

## payment-service

- **Port:** 8081
- **Architecture:** Hexagonal (Ports & Adapters)
- **Technical Stack:** Spring Boot, JPA, Hibernate, PostgreSQL, Kafka
- **Responsibility:** Receives payment requests, enforces idempotency, validates requests, persists transactions, and publishes domain events.
-------------------------

## fraud-service

- **Port:** 8083
- **Architecture:** Event-Driven Consumer/Producer
- **Technical Stack:** Spring Boot, Kafka Streams, Log MDC
- **Responsibility:** Performs fraud analysis, velocity checks, rule evaluation, and risk scoring before authorizing transactions.
-------------------------

## payment-worker

- **Port:** 8084
- **Architecture:** Decoupled Async Orchestrator
- **Technical Stack:** Spring WebFlux, WebClient, Reactive Redis, Kafka
- **Responsibility:** Coordinates transaction workflows, manages payment state transitions, processes asynchronous events, and orchestrates payment execution.
-------------------------

## provider-router-service

- **Port:** 8085
- **Architecture:** Stateless Utility Layer
- **Technical Stack:** Spring Boot, WebFlux, Reactive Netty Routing
- **Responsibility:** Selects payment providers, applies routing rules, transforms requests, and communicates with external banking and card-processing APIs.
-------------------------

## notification-service

- **Port:** 8086
- **Architecture:** Event-Driven Reactive Daemon
- **Technical Stack:** Spring Boot, Kafka Consumer Container
- **Responsibility:** Generates and delivers payment confirmations, receipts, email notifications, SMS messages, and system alerts.
-------------------------

## ledger-service

- **Port:** 8087
- **Architecture:** Hexagonal (Ports & Adapters)
- **Technical Stack:** Spring Boot, JPA, PostgreSQL, Kafka
- **Responsibility:** Maintains immutable double-entry accounting records and guarantees accurate financial settlement tracking.
-------------------------

## analytics-service

- **Port:** 8088
- **Architecture:** Real-Time Stream Processor
- **Technical Stack:** Spring Boot, Reactive JPA, PostgreSQL, Kafka
- **Responsibility:** Processes transaction events to calculate real-time metrics, merchant KPIs, throughput statistics, and operational analytics.
-------------------------

## reconciliation-service

- **Port:** 8089
- **Architecture:** Hexagonal Audit Engine
- **Technical Stack:** Spring Boot, JPA, PostgreSQL, Kafka
- **Responsibility:** Reconciles internal transaction records with external settlement reports, detects discrepancies, and supports financial audits.
-------------------------

## payment-infrastructure

- **Port:** 8090
- **Architecture:** Operational Automation Hub
- **Technical Stack:** Docker Compose, Spring Boot, Kafka, PostgreSQL
- **Responsibility:** Manages local development infrastructure, initializes Kafka topics, provisions databases, and performs system health validation.
-------------------------

## payment-ui

- **Port:** 3000
- **Architecture:** Decoupled UI Service Layer
- **Technical Stack:** React, TypeScript, Vite, Nginx
- **Responsibility:** Provides payment initiation screens, transaction tracking, merchant dashboards, reporting views, and administrative interfaces.
-------------------------
```
------------------------------
## 3. End-to-End Core Data Flow Sequence

```
[UI]        [Gateway]     [Payment-Svc]     [Kafka]     [Fraud-Svc]     [Worker]     [Router]     [External Rail]
 |              |               |              |             |             |            |                |
 |--(POST/Pay)->|               |              |             |             |            |                |
 |  (Header Auth & Correlation) |              |             |             |            |                |
 |              |--(Forward)--->|              |             |             |            |                |
 |              |               |--Check DBIdempotency       |             |            |                |
 |              |               |--Save CREATED State        |             |            |                |
 |              |               |--Send(payment-events)----->|             |            |                |
 |              |               |              |             |             |            |                |
 |              |<-(201 Resp)---|              |             |             |            |                |
 |<-(201 Init)--|               |              |             |             |            |                |
 |              |               |              |--Ingest---->|             |            |                |
 |              |               |              |             |--Calculate  |            |                |
 |              |               |              |             |--Send(fraud-events)----->|                |
 |              |               |              |             |             |            |                |
 |              |               |              |             |             |--Ingest----|                |
 |              |               |              |             |             |--AcquireRedisLock           |
 |              |               |              |             |             |--(POST ExecuteCharges)----->|
 |              |               |              |             |             |            |                |--Execute Wire
 |              |               |              |             |             |            |<-(200 Apprv)---|
 |              |               |              |             |             |--SaveOutcome                |
 |              |               |              |             |             |--ReleaseRedisLock           |
 |              |               |              |--Send(payment-succeeded)->|            |                |
 |              |               |              |             |             |--Commit Offset              |

```

------------------------------
## 4. Communication Strategy: Synchronous REST vs. Asynchronous Kafka
The selection of communication vectors across the platform mesh is explicitly divided by transactional boundary contexts:

## Where and Why Synchronous REST Is Utilized
* Perimeter-to-Ingestion Layer (payment-ui $\rightarrow$ payment-api-gateway $\rightarrow$ payment-service): Utilizes synchronous HTTP operations because the client application requires an immediate, deterministic handshake confirming that the transaction request was structurally valid, passed initial authorization constraints, and was successfully logged into the database ledger before moving to downstream async steps.
* Worker-to-Router Core (payment-worker $\rightarrow$ provider-router-service): Implemented via out-of-process synchronous HTTP endpoints, executed inside non-blocking asynchronous Java reactive loops (Mono). This request-reply paradigm is mandatory because routing decisions must be computed in real time based on active network gateway status metrics. Dropping this query onto a Kafka topic would force the worker thread to block or listen on volatile temporary tracking channels, creating a massive distributed message anti-pattern.

## Where and Why Asynchronous Kafka Is Utilized
* Post-Ingestion Processing Matrix (payment-service $\rightarrow$ fraud-service $\rightarrow$ payment-worker): Orchestrated over Kafka event logs to guarantee extreme throughput capacity and total service isolation. Ingestion is decoupled from calculation; if the fraud service goes down or undergoes maintenance, the payment service continues accepting transactions unhindered, storing events safely inside Kafka partitions until the consumers reboot.
* Downstream Financial Settlement Channels (payment-worker $\rightarrow$ ledger/analytics/reconciliation/notification): Leverages fan-out event-driven consumer topologies. The finalization of a charge emits a generic terminal event message (payment-succeeded or payment-failed). Downstream nodes handle bookkeeping, message delivery, and analytical counters concurrently and independently, completely protecting the core transaction processing critical paths from downstream blocking.

------------------------------
## 5. Data Isolation: The "Database-per-Service" Architecture
The Platform Constitution strictly enforces absolute data encapsulation by assigning independent database volumes and servers to each distinct logic repository:

* Elimination of Hard Tight Coupling: Traditional monolithic architectures rely on cross-domain relational table joins (e.g., combining a Payments table directly with an AccountingLedger table via SQL queries). In our platform, if multiple services read or write to the same schema layout, any schema modification crashes the entire application stack. By enforcing isolated database boundaries, a migration change inside the ledger-db has zero structural footprint or visibility within the reconciliation-db or payment-db.
* Fail-Safe Isolation Context: Shared database architectures introduce a catastrophic Single Point of Failure (SPOF). A corrupted index lock or heavy query spike within the analytical aggregation logic would lock up the shared transaction engine, taking down the entire credit intake pipeline. In our decoupled architecture, an extended relational locking block within the analytics-service database leaves the core ingestion API running completely unaffected.

------------------------------
## 6. Loose Coupling via Constructor-Based Dependency Injection
The platform leverages constructor-based dependency injection exclusively to enforce clear architectural separation, satisfying the Dependency Inversion Principle.

```
// Demonstration of compile-time decoupling via constructor injection
@Componentpublic class PaymentRepositoryAdapter implements PaymentRepository {
    private final SpringDataPaymentRepository jpaRepository;

    public PaymentRepositoryAdapter(SpringDataPaymentRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }
    // ...
}
```

* Pristine Application Isolation: The business use-case layers (payment-service, payment-worker) are compiled with zero references to specific concrete infrastructure classes, data drivers, or annotations. They declare their input/output requirements via clean, local interface port descriptors (PaymentRepository, IdempotencyCache).
* Startup Injection Mappings: At startup, Spring scans the context, identifies the infrastructure-layer implementations (e.g., PaymentRepositoryAdapter, RedisIdempotencyCacheAdapter), and injects those adapter instances directly into the use-case constructors. This design means you can swap your entire caching layout from Redis to an in-memory cache grid without altering a single line of core payment orchestration logic.

------------------------------
## 7. Clean Architecture & SOLID Implementation Blueprint
The core processing engines are structured strictly according to the rules of Hexagonal (Ports and Adapters) Clean Architecture, ensuring that dependencies point uniformly inward toward the business rules layer:

```
+-----------------------------------------------------------------------+
|  INFRASTRUCTURE LAYER (Adapters, Web Controllers, JPA, Redis, Kafka)  |
|   +---------------------------------------------------------------+   |
|   |  APPLICATION LAYER (Use-Cases, Orchestration, Abstract Ports) |   |
|   |   +-------------------------------------------------------+   |   |
|   |   |  DOMAIN LAYER (Pristine Entities, Pure Business Rules)|   |   |
|   |   +-------------------------------------------------------+   |   |
|   +---------------------------------------------------------------+   |
+-----------------------------------------------------------------------+
```

* The Single Responsibility Principle (SRP): Every component has exactly one reason to change. The Payment entity regulates internal state machine properties. The PaymentService manages ingestion transactions. The PaymentController is strictly responsible for parsing JSON network requests and header variables, ensuring that changes to HTTP endpoints do not bleed into accounting calculation configurations.
* The Open/Closed Principle (OCP): Microservice data schemas are modeled as immutable Java 21 Record structures (PaymentCreatedEvent). New system functionalities or consumers can be added to the platform topology at any time by configuring new Kafka listener modules, without modifying or repackaging existing production ingestion components.
* The Liskov Substitution Principle (LSP): Every outbound infrastructure adapter class implements an abstract domain port interface verbatim. The RedisIdempotencyCacheAdapter replaces the abstract IdempotencyCache contract completely and transparently, adhering strictly to its null-safety definitions and stream flow signatures.
* The Interface Segregation Principle (ISP): Instead of creating giant, monolithic database interfaces, the platform declares lean, purpose-specific port registries. The PaymentRepository port contains only the minimal set of query signatures required by the domain ingestion use-case, keeping the core system unburdened by redundant data handling structures.

------------------------------
## 8. Two-Layer Distributed Idempotency Framework
To safeguard the ecosystem against accidental duplicate billing execution routines during high-concurrency network failures, the platform implements Two-Layer Idempotency Walls:

## Layer 1: The API Perimeter Protection Wall (payment-service)
* Target Invariant: Protects internal transactional database schemas from duplicate HTTP ingestion mutations.
* Mechanics: When a client submits a charge request, the payment-service extracts the unique tracking string from the X-Correlation-ID header. It checks the primary relational database table index. If that correlation value matches an existing database entry record, it immediately intercepts the request, short-circuits execution, and returns a safe duplicate status message, preventing duplicate ledger entries.

## Layer 2: The Distributed Streaming Execution Wall (payment-worker)

* Target Invariant: Protects external third-party banking APIs (Stripe/Adyen) from duplicate charging actions caused by Kafka message redeliveries.
* Mechanics: Kafka guarantees at-least-once message delivery. If an internal container network drops or a broker node restarts while transmitting events, the same FraudEvaluatedEvent payload can be delivered to the payment-worker multiple times.
* Before calling the router service, the worker invokes an atomic distributed setIfAbsent lock command on a high-speed Redis memory grid data topology using the transaction tracking string. If a duplicate consumer thread attempts to process the message simultaneously, it fails to acquire the Redis lock lease and is safely rejected. This guarantees that your business code communicates with the external banking network exactly once.

------------------------------
## 9. Perimeter Security: Centralized Stateless OAuth2 & JWT Verification
The platform isolates authorization checking entirely within the perimeter layer using an asymmetric token framework:

* Centralized Edge Validation: Individual downstream processing containers (like payment-worker or provider-router-service) are completely insulated from parsing authorization database structures or executing user profile queries. The perimeter payment-api-gateway intercepts every incoming HTTP request, validates its digital signature against a cryptographically signed cryptographic JWT public key, extracts scopes, and attaches a sanitized transaction context downstream.
* Stateless Scaling Loop Advantages: Because token verification is handled mathematically at the gateway boundary, downstream business microservices operate completely state-free. They do not waste memory buffers or introduce network connection bottlenecks by constantly making cross-network requests back to a central session tracking database, allowing the entire Kubernetes pod replica ecosystem to scale up block-freely.


