# AI Prompt Master Blueprint
## AI Prompt Engineering Blueprint (AI-PROMPT.md)
This document contains a structured orchestration blueprint designed to guide any conversational or autonomous AI agent (such as Cline, Cursor, Claude, ChatGPT, or DeepSeek) through implementing the remaining backend modules of the platform.
------------------------------
## 1. Initial Context Ingestion (The Initialization Prompt)
Execute this prompt as the first message in a fresh AI chat session. It locks the assistant into your Spec-Driven Development architecture before generating any files.

You are an expert enterprise backend engineer specializing in Spec-Driven Development (SDD), Java 21, Spring Boot 3.x, and Clean Architecture. 

We are developing a high-volume, reactive payment processing platform organized as a multi-repository workspace. To guide your development, you have access to two authoritative markdown files in our workspace context:
1. @openspec/project.md (The Platform Constitution - detailing clean architecture layers, immutability laws, and coding invariants).
2. @openspec/specs/[TARGET_SERVICE_NAME]/spec.md (The specific functional requirements and behavioral criteria for this service).

CRITICAL OPERATIONAL RULES:
- Read both files completely before proposing an implementation or writing code files.
- You must strictly enforce Java 21 features (Records, Sealed Interfaces, Pattern Matching, Pattern Matching for Switch) instead of legacy boilerplates.
- You are forbidden from using Lombok annotations (@Data, @Builder, @AllArgsConstructor, etc.). All data structures must rely on native Java syntax.
- Domain layer models must contain ZERO framework dependencies (no Spring, no Jakarta/JPA annotations). Frameworks belong exclusively to the Infrastructure layer.
- Do not abbreviate or write placeholders like "// TODO" or "...". Generate complete, functional, compilable code files.

Acknowledge these instructions and state the primary structural rules of our Platform Constitution before we begin writing code.

------------------------------
## 2. Step-by-Step Microservice Scaffolding Sequence
Once the AI agent acknowledges the setup, execute the following prompt sequences one by one to implement the target repository.
## Step 2.1: The Local Build Configuration

Please read @openspec/specs/[TARGET_SERVICE_NAME]/spec.md and generate a production-ready, clean Apache Maven `pom.xml` configuration file inside the root directory of this repository. 

The configuration requirements are:
1. It MUST inherit cleanly from the master platform parent POM found inside the `shared-contracts` repository.
2. It must explicitly declare the required dependencies specified in the spec file (e.g., Spring Cloud Gateway for the API Gateway, or Spring Kafka and Spring Boot Starter Data JPA for backend processing services).
3. It must import the `shared-contracts` library dependency to gain access to our unified API DTOs and Kafka domain events.
4. It must contain zero Lombok dependencies and enforce clear compiler parameters for Java 21.

## Step 2.2: The Domain Layer (Entities & Invariants)

Based strictly on the behavioral rules and domain requirements in the spec, please generate the core Domain Models and Aggregate Roots for this service under the `com.payment.platform.[service_name].domain.model` package.

Ensure that:
1. All domain objects are written as clean Java classes or immutable records.
2. They contain zero external framework or database annotations (no JPA `@Entity`, `@Table`, or `@Id`).
3. State transitions are explicitly encapsulated as internal validation methods that throw descriptive domain exceptions if invalid hops are attempted.
4. If the service emits domain messages, provide a mechanism within the aggregate root to capture an internal list of immutable domain events for transactional outbox routing.

## Step 2.3: The Domain Ports (Adapter Interfaces)

Please generate the boundary Port interfaces for the domain layer under the `com.payment.platform.[service_name].domain.repository` or `com.payment.platform.[service_name].domain.port` packages.

This includes:
1. Outbound Repository ports defining contract methods for state persistence and retrieval (decoupled from actual database implementations).
2. Outbound Message Broker ports defining contract methods for broadcasting transactional notifications or domain events.

## Step 2.4: The Application Layer (Use Case Command Handlers)

Please create the application core Use Case interactors and Command Handlers under the `com.payment.platform.[service_name].application.usecase` package.

Ensure that:
1. Each use case is an independent, specialized component class (e.g., `CreatePaymentUseCase`, `ProcessReconciliationUseCase`).
2. The handlers orchestrate the business workflow by looking up idempotency keys, loading aggregates via domain repository ports, executing state transition logic on the aggregates, and saving the updated states back through the ports.
3. The entire sequence is wrapped cleanly within a transactional Unit of Work to enforce strict consistency boundaries.

## Step 2.5: The Infrastructure Layer (Adapters & Rest/Kafka Controllers)

Please generate the concrete Infrastructure layer adapters under the `com.payment.platform.[service_name].infrastructure` package.

Implement:
1. Inbound REST Controllers or reactive routing handlers mapping HTTP request vectors to application use cases. Ensure requests are validated via `jakarta.validation` rules before executing handlers.
2. Inbound Kafka Message Listeners or event consumers handling incoming data streams. They must ingest `BaseEvent` payloads and use type-safe switch blocks or pattern matching to route messages safely.
3. Outbound Database Adapters implementing your domain repository ports using Spring Data JPA or reactive repositories. Ensure that saving an aggregate automatically processes and flushes its internal transactional outbox events to guarantee message delivery reliability.

## Step 2.6: Comprehensive Unit Test Suite

Based on the generic validation scenarios and GIVEN/WHEN/THEN criteria enumerated in the specification file, please generate a comprehensive JUnit 5 unit test suite for this microservice under the `src/test/java` directory.

The test suite must:
1. Mock all outbound infrastructure ports using Mockito to isolate the application core.
2. Explicitly verify every happy-path state transition and edge-case error boundary scenario detailed in the spec.
3. Assert that validation errors throw standardized platform exceptions and emit correct tracking data.


