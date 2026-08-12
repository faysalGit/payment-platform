# AI Prompt Engineering Master Template for Spec-Driven Development

Keep this file saved as `AI-PROMPT.md` at the absolute root of your `payment-platform` workspace. When you are ready to begin implementing a new microservice repository, copy and paste these prompt phases sequentially into your AI chat assistant (such as Cline, Claude Code, or Cursor).

---

## Phase 1: Ingestion & Context Anchoring
**Goal**: Feed the core design rules and system constraints into the AI session to eliminate hallucinations before a single line of code is generated.

### Execution Prompt
"You are an expert enterprise Java software engineer operating within a strict Spec-Driven Development (SDD) ecosystem. Before generating files, writing code, or suggesting application logic, you must fully anchor your session to our platform blueprints.

Please read and analyze the following markdown documents from our workspace:
1. Global Platform Constitution: `@openspec/project.md`
2. Service Functional Specification: `@openspec/specs/[INSERT_SERVICE_NAME_HERE]/spec.md`
3. Platform CI/CD & Azure Deployment Invariants: `@openspec/specs/cicd-architecture/spec.md`

Do not generate any code or create directories yet. Acknowledge your ingestion of these three documents by summarizing:
- The core business responsibility of this specific microservice.
- The strict architectural boundaries dictated by our Clean Architecture paradigm (e.g., framework isolation).
- The exact containerization and deployment models required by our Azure Kubernetes Service (AKS) and Azure Pipelines integration guidelines.
Confirm that you are ready to implement this service using pure Java 21, zero Lombok annotations, and clean record syntax."

---

## Phase 2: Scaffolding & Build Configuration
**Goal**: Build a clean, compilable project directory layout with synchronized library dependencies.

### Execution Prompt
"Based strictly on the build parameters outlined in `@openspec/project.md` and the service rules in `@openspec/specs/[INSERT_SERVICE_NAME_HERE]/spec.md`, please generate a production-ready Apache Maven `pom.xml` configuration file at the root of the local microservice directory.

The configuration must:
- Cleanly inherit from our master platform parent POM.
- Explicitly declare Java 21 compilation source and target parameters.
- Import the compiled `shared-contracts` library dependency jar.
- Include only the minimal, non-blocking third-party starter frameworks specified for this sub-domain (e.g., Spring Boot, Database Drivers, or Reactive Messaging).
- Contain absolutely zero references to Lombok or deprecated build plugins.

Once the `pom.xml` file is written, write a minimalist, non-blocking main bootstrap application entry point class within the appropriate root base package."

---

## Phase 3: Bounded Context Domain Models
**Goal**: Implement pure business entities and data invariants isolated from databases or presentation concerns.

### Execution Prompt
"Reviewing the domain logic and GIVEN/WHEN/THEN behavior rules in `@openspec/specs/[INSERT_SERVICE_NAME_HERE]/spec.md`, please generate the core domain layer objects within the internal application core package.

Follow these strict domain boundaries:
- Use immutable Java 21 records to represent value objects, transactional inputs, and data containers.
- Ensure the domain objects contain zero external framework metadata, persistence layer mapping parameters (no JPA/Hibernate annotations), or web controller indicators.
- Encapsulate all business validation rules directly inside the canonical constructor paths of the records, throwing explicit domain exceptions if structural invariants are violated."

---

## Phase 4: Application Use Cases, Ports, & Business Logic
**Goal**: Build the operational use case command handlers and declare the boundaries for external persistence adapters.

### Execution Prompt
"Based on the operational flows detailed in the service specification, please implement the application layer use cases and business logic service flows.

You must follow these rules:
- Separate data commands from informational queries.
- Declare explicit interface boundaries (Ports/Repositories) for any external operations, such as database lookups, cache checks, or event publishing actions. Do not provide the implementations yet.
- Inject these repository interface boundaries into your use case handlers using standard, native Java constructor injection (no `@Autowired` fields).
- Ensure all operations map tracking parameters correctly by propagating the mandatory `X-Correlation-ID` header value throughout the active execution context."

---

## Phase 5: Infrastructure Adapters & Pipeline Realization
**Goal**: Complete the operational layer by providing concrete web controllers, database adapters, Dockerfiles, and Azure Pipelines.

### Execution Prompt
"With the core domain and application layer compile-verified, please implement the concrete infrastructure integration boundaries.

Please generate:
1. Rest controllers or reactive event listeners that map incoming transport objects to our immutable `shared-contracts` DTO formats.
2. Concrete database adapter repositories that translate domain state models into persistence layout tables cleanly.
3. A multi-stage `Dockerfile` sitting at the root of this microservice folder, following the exact multi-stage openjdk compilation caching layers laid out in `@openspec/specs/cicd-architecture/spec.md`.
4. A fully operational, credential-isolated `azure-pipelines.yml` deployment script at the service root, mapping build triggers to Azure DevOps pipelines and targeting our private Azure Container Registry (ACR) and Azure Kubernetes Service (AKS) namespaces exactly as dictated by the deployment spec.

Ensure all infrastructure adapters remain strictly decoupled from the core application layer logic."
