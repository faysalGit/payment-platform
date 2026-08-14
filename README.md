# Global Platform Master Workspace Blueprint
## High-Volume Payment Processing Platform
Welcome to the root development workspace of the High-Volume Payment Processing Platform. This project is built using a Spec-Driven Development (SDD) model via OpenSpec, enforcing strict decoupling between system behavior, configuration matrices, and actual Java 21 / Spring Boot 3 microservice codebases.
------------------------------
## 1. Multi-Repository Directory Structure
This workspace uses a multi-root architecture mapped via payment-platform.code-workspace. The platform is divided into 12 independent repositories grouped by their operational responsibility:

```
payment-platform/                  # Root Workspace Directory
├── .clinerules                    # Global AI assistant engineering laws
├── AI-PROMPT.md                   # Master AI context execution framework
├── payment-platform.code-workspace # Multi-root IDE configuration registry
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
│       ├── cicd-architecture/spec.md # Centralized CI/CD & pipeline specs
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
```
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
   15. CI/CD & Deployment (specs/cicd-architecture/spec.md): Outlined the enterprise secure deployment topology mapping GitHub code triggers natively to internal automated Azure Pipelines execution loops.
   16. User Interface Canvas (specs/payment-ui/spec.md): Standardized a React + TypeScript SPA boundary designed to react to backend REST error structures, inject client-side idempotency tracking markers, and handle sensitive cardholder profiles inside secure iframes.

------------------------------
## 3. Azure DevOps CI/CD Integration Framework
To ensure maximum security and isolate operational credentials from your open code platforms, the architecture segregates source code hosting from operational build execution:

* Source Code Control Plane: GitHub acts strictly as a stateless, git-history tracking plane. No infrastructure credentials, service principal JSON certificates, or cluster secrets are saved within your GitHub repository parameters.
* Isolated Build Execution: Azure DevOps (dev.azure.com) hooks directly into your GitHub webhooks using secure OAuth Service Connections. All automated verification compiles (mvn clean test), Docker layering routines, and Kubernetes rollout procedures execute strictly inside isolated Azure-hosted agent pools.

## Local Component Integration Layout
Each individual microservice repository utilizes two unified files sitting at its absolute root folder path to interface with this deployment mesh:

   1. Dockerfile: A multi-stage, non-root execution recipe that uses an eclipse-temurin Java 21 JDK layer to run test suites, strips out compilation tooling overheads, and copies the execution artifact over to a hardened Alpine JRE runtime shell.
   2. azure-pipelines.yml: A declarative pipeline structure defining individual execution blocks for staging compilations, building and push operations to Azure Container Registry (ACR), and zero-downtime manifest bakes directly into your Azure Kubernetes Service (AKS) namespaces.

------------------------------
## 4. Local Development Execution Loop
When building out codebases within any individual repository, adhere to the single source of truth:

* Run OpenSpec validation (or your pipeline's lint command) to guarantee local implementations do not violate the core requirements written in the openspec/specs/ directory.
* Ensure all code modifications preserve the separation of concerns between API, Application, Domain, and Infrastructure modules defined in the platform constitution.

------------------------------
## 5. Rationale and Strategic Sequencing Breakdown
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

* The Strategy: Record and audit the resulting transactional mutations securely. Once an integration strategy resolves a provider response, the outcome becomes formal financial record data. It must be appended immutably to a corporate journal (Ledger) and cross-checked against external settlement assets (Reconciliation).
* The Rationale: Positioning the ledger and reconciliation components here completes the functional transaction stream loop, ensuring total data auditability from edge entry to settling files.

## Phase 5: Shared Contracts & Downstream Utilities (Steps 11–13)

* The Strategy: Abstract the settled domain patterns into reusable network contract libraries. Once core processing engines, workers, and ledger persistence schemas are validated, their shared messaging payloads are centralized into a versioned registry (shared-contracts). This creates the foundation for decoupled, reactive notification and analytics systems.
* The Rationale: Because notifications and telemetry engines are pure downstream consumers of system data, designing them earlier would have resulted in unvalidated schema assumptions and pipeline breakage during structural changes.

## Phase 6: Cloud Provisioning & Visual Consumption (Steps 14–16)

* The Strategy: Construct the surrounding environmental, automation pipeline, and client layers around the backend architecture. Infrastructure-as-Code modules build the physical cloud topologies (subnets, AKS clusters, secret vaults) matching the service map. CI/CD scripts establish the continuous integration parameters, and the frontend interface serves as the final consumption plane.
* The Rationale: Designing infrastructure rules, integration automation loops, and user experiences last ensures they match your backend constraints perfectly. Because the UI layer has visibility over gateway error contracts (e.g., HTTP 429), state structures, and pagination signatures, it can be engineered cleanly without guessing API specifications.


## Section 1: Central Data Contract Library (shared-contracts)1. 
**1. Purpose & Scope**: This repository operates as the absolute domain contract and data schema foundation for the entire platform workspace. To maximize flexibility, readability, and portability, it is designed to be completely framework-free, containing zero external runtime dependencies on Spring Boot, Spring Kafka, or database persistence engines. It distributes unified, unalterable plain Java event structures across out-of-process boundaries via classpath JAR injection.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\shared-contracts\
   * Package Structure:
```
📁 shared-contracts/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        └── 📁 java/
            └── 📁 com/
                └── 📁 payment/
                    └── 📁 platform/
                        ├── 📁 fraud/
                        │   └── 📁 messaging/
                        │       └── 📄 FraudEvaluatedEvent.java
                        └── 📁 payment/
                            └── 📁 service/
                                └── 📄 PaymentCreatedEvent.java
```

**3. Contract Schema Blueprints**

__Transaction Initiation Payload (com/payment/platform/payment/service/PaymentCreatedEvent.java)__

```
// java
package com.payment.platform.payment.service;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * Immutable domain event emitted onto the 'payment-events' Kafka topic
 * when a fresh transaction initializes in a pending state.
 */
public record PaymentCreatedEvent(
    String transactionId,
    String customerId,
    BigDecimal amount,
    String currency,
    String status,
    Instant createdAt
) {}
```
__Risk Evaluation Analytics Payload (com/payment/platform/fraud/messaging/FraudEvaluatedEvent.java)__

```
// java
package com.payment.platform.fraud.messaging;

/**
 * Immutable evaluation result event broadcast by the risk scoring engine
 * back onto the 'fraud-events' message cluster stream.
 */
public record FraudEvaluatedEvent(
    String transactionId,
    String correlationId,
    String decision,
    int riskScore,
    String failureReason
) {}
```

## Section 2: Edge Perimeter API Gateway (payment-api-gateway)
**1. Purpose & Scope**: This repository establishes your edge routing proxy boundaries on public port 8080. It secures inbound traffic by validating OAuth2 JWT tokens, mandates the presence of a non-empty Idempotency-Key header for mutations, routes traffic non-blockingly, and injects invariant X-Correlation-ID markers into downstream request threads to ensure end-to-end tracing across service boundaries.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\payment-api-gateway\
   * Directory Structure:
   
```
📁 payment-api-gateway/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        ├── 📁 java/
        └── 📁 resources/
            └── 📄 application.yml
```

**3. Edge Routing Profile Configuration (src/main/resources/application.yml)**

```
server:
  port: 8080

spring:
  application:
    name: payment-api-gateway
  cloud:
    gateway:
      globalcors:
        cors-configurations:
          '[/**]':
            allowedOrigins: "*"
            allowedMethods: [GET, POST, PUT, DELETE, OPTIONS]
            allowedHeaders: "*"
            exposedHeaders: ["X-Correlation-ID"]
      routes:
        - id: payment-service-route
          uri: http://payment-service-svc:8081
          predicates:
            - Path=/api/v1/payments/**
        - id: analytics-service-route
          uri: http://analytics-service-svc:8088
          predicates:
            - Path=/api/v1/analytics/**
        - id: ledger-service-route
          uri: http://ledger-service-svc:8087
          predicates:
            - Path=/api/v1/ledger/**
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://microsoftonline.com
          jwk-set-uri: https://microsoftonline.com
```

## Section 3: Core Transaction Ingestion Service (payment-service)
**1. Purpose & Scope**: Serves as your primary synchronous REST transaction ingestion API engine on port 8081. Following a strict Clean Architecture pattern, it converts incoming JSON web payloads into framework-insulated domain entities, records payment intents safely into a relational database outbox table, and wraps the web layer in global HTTP exception handling walls.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\payment-service\
   * Directory Structure:

```
📁 payment-service/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        └── 📁 java/
            └── 📁 com/
                └── 📁 payment/
                    └── 📁 platform/
                        └── 📁 payment/
                            ├── 📁 domain/
                            │   ├── 📁 model/
                            │   │   └── 📄 Payment.java
                            │   └── 📁 ports/
                            │       └── 📄 PaymentRepository.java
                            ├── 📁 infrastructure/
                            │   ├── 📁 config/
                            │   │   └── 📄 KafkaTopicConfig.java
                            │   └── 📁 persistence/
                            ├── 📁 service/
                            │   └── 📄 PaymentService.java
                            └── 📁 web/
                                ├── 📄 PaymentController.java
                                └── 📄 GlobalExceptionHandler.java
```

**3. Core Operational Code Blueprints**

__Clean Architecture Domain POJO Entity (domain/model/Payment.java)__

```
// java

package com.payment.platform.payment.domain.model;

import java.math.BigDecimal;
import java.time.Instant;

public class Payment {
    private String id;
    private String customerId;
    private BigDecimal amount;
    private String currency;
    private String status;
    private Instant createdAt;

    public Payment() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getCustomerId() { return customerId; }
    public void setCustomerId(String customerId) { this.customerId = customerId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
```
__Central HTTP Ingress Global Exception Handler Advice (web/GlobalExceptionHandler.java)__

```
// java

package com.payment.platform.payment.web;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import java.net.URI;
import java.time.Instant;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ProblemDetail handleInvalidInput(IllegalArgumentException ex) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, ex.getMessage());
        problem.setTitle("Invalid Transaction Parameters");
        problem.setType(URI.create("https://payment-platform.com"));
        problem.setProperty("timestamp", Instant.now());
        return problem;
    }

    @ExceptionHandler(Exception.class)
    public ProblemDetail handleGenericFailure(Exception ex) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(HttpStatus.INTERNAL_SERVER_ERROR, "An unexpected transactional error occurred.");
        problem.setTitle("Internal Processing Error");
        problem.setProperty("timestamp", Instant.now());
        return problem;
    }
}
```
__Programmatic Broker Topic Provisioning Config (infrastructure/config/KafkaTopicConfig.java)__

```
// java

package com.payment.platform.payment.infrastructure.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaTopicConfig {

    @Bean
    public NewTopic paymentEventsTopic() {
        return TopicBuilder.name("payment-events").partitions(3).replicas(1).build();
    }

    @Bean
    public NewTopic fraudEventsTopic() {
        return TopicBuilder.name("fraud-events").partitions(3).replicas(1).build();
    }

    @Bean
    public NewTopic paymentEventsDlt() {
        return TopicBuilder.name("payment-events.DLT").partitions(3).replicas(1).build();
    }
}
```

## Section 4: Risk Evaluation Engine Service (fraud-service)
**1. Purpose & Scope**: Operates on port 8083 as an asynchronous stream filter. It processes incoming transaction initialization alerts from Kafka, handles context logging blocks via MDC tracing scopes, computes velocity indicators, and encapsulates streaming failures inside local consumer error handlers.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\fraud-service\
   * Directory Structure:
```
📁 fraud-service/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        └── 📁 java/
            └── 📁 com/
                └── 📁 payment/
                    └── 📁 platform/
                        └── 📁 fraud/
                            ├── 📁 domain/
                            └── 📁 infrastructure/
                                ├── 📁 config/
                                │   └── 📄 KafkaConsumerConfig.java
                                └── 📁 messaging/
                                    └── 📄 PaymentEventKafkaConsumer.java
```

**3. Asynchronous Consumer Code Architecture**

__Programmatic Kafka Fallback Error Boundary (infrastructure/config/KafkaConsumerConfig.java)__

```
// java

package com.payment.platform.fraud.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.DeadLetterPublishingRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.util.backoff.FixedBackOff;

@Configuration
public class KafkaConsumerConfig {

    @Bean
    public DefaultErrorHandler errorHandler(KafkaTemplate<Object, Object> template) {
        DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template);
        DefaultErrorHandler errorHandler = new DefaultErrorHandler(recoverer, new FixedBackOff(1000L, 3L));
        errorHandler.setCommitRecovered(true);
        return errorHandler;
    }
}
```

__Asynchronous Inbound Stream Consumer Adapter (infrastructure/messaging/PaymentEventKafkaConsumer.java)__

```
// java

package com.payment.platform.fraud.infrastructure.messaging;

import com.payment.platform.payment.service.PaymentCreatedEvent;
import com.payment.platform.fraud.messaging.FraudEvaluatedEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Component;

@Component
public class PaymentEventKafkaConsumer {

    private static final Logger log = LoggerFactory.getLogger(PaymentEventKafkaConsumer.class);
    private static final String CORRELATION_HEADER = "X-Correlation-ID";
    private final KafkaTemplate<String, Object> kafkaTemplate;

    public PaymentEventKafkaConsumer(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    @KafkaListener(topics = "payment-events", groupId = "${spring.kafka.consumer.group-id}", containerFactory = "kafkaListenerContainerFactory")
    public void onPaymentCreated(PaymentCreatedEvent event, Acknowledgment acknowledgment) {
        String correlationId = event.transactionId();
        MDC.put(CORRELATION_HEADER, correlationId);
        log.info("Fraud engine received transaction for analysis. ID: {}, Amount: {}", event.transactionId(), event.amount());

        try {
            String decision = "APPROVED";
            String reason = "Risk metrics within standard corporate tolerances.";
            int riskScore = 15;

            if (event.amount() != null && event.amount().compareTo(new java.math.BigDecimal("10000")) > 0) {
                decision = "REJECTED";
                reason = "Transaction volume breaches velocity limit checks.";
                riskScore = 85;
                log.warn("Velocity limit threshold breach caught. Marking transaction as REJECTED.");
            }

            FraudEvaluatedEvent evaluationResult = new FraudEvaluatedEvent(
                    event.transactionId(),
                    correlationId,
                    decision,
                    riskScore,
                    reason
            );

            kafkaTemplate.send("fraud-events", correlationId, evaluationResult)
                    .whenComplete((result, ex) -> {
                        if (ex != null) {
                            log.error("Failed to distribute risk verification metrics downstream to Kafka.", ex);
                        } else {
                            log.info("Risk calculation successfully broadcasted to topic fraud-events.");
                            acknowledgment.acknowledge();
                        }
                    });

        } catch (Exception e) {
            log.error("Fatal exception intercepted inside streaming risk calculation loop.", e);
            throw e;
        } finally {
            MDC.remove(CORRELATION_HEADER);
        }
    }
}
```

## Section 5: Asynchronous Processing Orchestrator (payment-worker)
**1. Purpose & Scope**: Runs on port 8084 to handle multi-step payment execution. It listens for risk verification signals, locks atomic idempotency tokens inside Redis via transaction strings to prevent execution races, invokes out-of-process bank rails, and emits definitive settlement signals onto the Kafka cluster mesh.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\payment-worker\
   * Directory Structure:
```
📁 payment-worker/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        └── 📁 java/
            └── 📁 com/
                └── 📁 payment/
                    └── 📁 platform/
                        └── 📁 worker/
                            ├── 📁 domain/
                            └── 📁 infrastructure/
                                ├── 📁 config/
                                │   └── 📄 KafkaConsumerConfig.java
                                └── 📁 messaging/
                                    └── 📄 FraudEventKafkaConsumer.java
```

**3. Consumer Operational Configuration Engine (infrastructure/config/KafkaConsumerConfig.java)**

```
package com.payment.platform.worker.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.DeadLetterPublishingRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.util.backoff.FixedBackOff;

@Configuration
public class KafkaConsumerConfig {

    @Bean
    public DefaultErrorHandler errorHandler(KafkaTemplate<Object, Object> template) {
        DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template);
        DefaultErrorHandler errorHandler = new DefaultErrorHandler(recoverer, new FixedBackOff(1000L, 3L));
        errorHandler.setCommitRecovered(true);
        return errorHandler;
    }
}
```
## Section 6: Stateless Provider Router Service (provider-router-service)
**1. Purpose & Scope**: An isolated outbound proxy router operating on port 8085. It exposes a stateless ingestion API endpoint to the worker, dynamically evaluates transactional routing metrics, and manages standard form-urlencoded integration envelopes across banking networks via reactive, non-blocking WebClient handlers.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\provider-router-service\
   * Directory Structure:
```
📁 provider-router-service/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        └── 📁 java/
            └── 📁 com/
                └── 📁 payment/
                    └── 📁 platform/
                        └── 📁 router/
                            ├── 📁 domain/
                            ├── 📁 application/
                            │   └── 📁 ports/
                            │       └── 📄 BankingGatewayClient.java
                            └── 📁 infrastructure/
                                └── 📁 client/
                                    └── 📄 WebClientBankingGatewayClient.java
```

**3. Non-Blocking Integration Webflux Client Blueprint (infrastructure/client/WebClientBankingGatewayClient.java)**

```
// java

package com.payment.platform.router.infrastructure.client;

import com.payment.platform.router.application.ports.BankingGatewayClient;
import com.payment.platform.router.domain.model.TransactionDetails;
import com.payment.platform.router.domain.model.RoutingDecision;
import com.payment.platform.router.domain.model.ProviderType;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Component
public class WebClientBankingGatewayClient implements BankingGatewayClient {

    private final WebClient webClient;

    public WebClientBankingGatewayClient(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.build();
    }

    @Override
    public Mono<RoutingDecision> authorizeTransaction(TransactionDetails details, ProviderType targetProvider) {
        String gatewayUrl = targetProvider == ProviderType.STRIPE ? "https://stripe.com" : "https://adyen.com";

        return this.webClient.post()
            .uri(gatewayUrl)
            .contentType(MediaType.APPLICATION_FORM_URLENCODED)
            .bodyValue("amount=" + details.getAmount().toBigInteger().toString() + "&currency=" + details.getCurrency().toLowerCase())
            .retrieve()
            .bodyToMono(String.class)
            .map(response -> new RoutingDecision(details.getTransactionId(), targetProvider, "SUCCESS", "auth_token_mock"))
            .onErrorResume(ex -> Mono.just(new RoutingDecision(details.getTransactionId(), targetProvider, "FAILED", ex.getMessage())));
    }
}
```

## Section 7: Notification Alert Engine (notification-service)
**1. Purpose & Scope**: Acts as an asynchronous messaging fan-out daemon running on port 8086. It intercepts payment-succeeded and payment-failed event metrics across the broker cluster, executes localized user template mapping lookups, and triggers outbound customer alerting receipts.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\provider-router-service\
   * Directory Structure:
```
📁 notification-service/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        └── 📁 java/
            └── 📁 com/
                └── 📁 payment/
                    └── 📁 platform/
                        └── 📁 notification/
                            ├── 📁 domain/
                            └── 📁 infrastructure/
                                ├── 📁 config/
                                │   └── 📄 KafkaConsumerConfig.java
                                └── 📁 messaging/
                                    └── 📄 PaymentResultKafkaConsumer.java
```

**3. Consumer Resiliency Middleware Layout (infrastructure/config/KafkaConsumerConfig.java)**

```
// java 

package com.payment.platform.notification.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.DeadLetterPublishingRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.util.backoff.FixedBackOff;

@Configuration
public class KafkaConsumerConfig {

    @Bean
    public DefaultErrorHandler errorHandler(KafkaTemplate<Object, Object> template) {
        DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template);
        DefaultErrorHandler errorHandler = new DefaultErrorHandler(recoverer, new FixedBackOff(1000L, 3L));
        errorHandler.setCommitRecovered(true);
        return errorHandler;
    }
}
```

## Section 8: Immutable Financial Core (ledger-service)
**1. Purpose & Scope**: Maintains complete platform audit and double-entry accounting integrity on port 8087. It consumes final terminal settlement records from the broker mesh and generates zero-sum DEBIT/CREDIT ledger records, throwing hard errors on any manual data mutation attempts.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\ledger-service\
   * Directory Structure:
```
📁 ledger-service/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        └── 📁 java/
            └── 📁 com/
                └── 📁 payment/
                    └── 📁 platform/
                        └── 📁 ledger/
                            ├── 📁 domain/
                            │   ├── 📁 model/
                            │   │   └── 📄 LedgerEntry.java
                            │   └── 📁 ports/
                            └── 📁 infrastructure/
                                ├── 📁 config/
                                │   └── 📄 KafkaConsumerConfig.java
                                └── 📁 messaging/
```

**3. Financial Log Implementation Specifications**

__Domain Aggregate Ledger Entry Record (domain/model/LedgerEntry.java)__

```
// java

package com.payment.platform.ledger.domain.model;

import java.math.BigDecimal;
import java.time.Instant;

public class LedgerEntry {
    private String id;
    private String transactionId;
    private String accountId;
    private BigDecimal amount;
    private String type; // DEBIT or CREDIT
    private Instant timestamp;

    public LedgerEntry() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public Instant getTimestamp() { return timestamp; }
    public void setTimestamp(Instant timestamp) { this.timestamp = timestamp; }
}
```
__Consumer Pipeline Error Boundary Advisor (infrastructure/config/KafkaConsumerConfig.java)__

```
// java

package com.payment.platform.ledger.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.DeadLetterPublishingRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.util.backoff.FixedBackOff;

@Configuration
public class KafkaConsumerConfig {

    @Bean
    public DefaultErrorHandler errorHandler(KafkaTemplate<Object, Object> template) {
        DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template);
        DefaultErrorHandler errorHandler = new DefaultErrorHandler(recoverer, new FixedBackOff(1000L, 3L));
        errorHandler.setCommitRecovered(true);
        return errorHandler;
    }
}
```

## Section 9: Real-Time Analytics Stream (analytics-service)
**1. Purpose & Scope**: Operating as a read-optimized query manager on port 8088, this repository intercept final transaction outcomes non-blockingly. It executes high-speed analytical counters updates inside sliding time windows to power live reporting panels while insulating write-heavy cores from table locking contention.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\analytics-service\
   * Directory Structure:
```
📁 analytics-service/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        └── 📁 java/
            └── 📁 com/
                └── 📁 payment/
                    └── 📁 platform/
                        └── 📁 analytics/
                            ├── 📁 domain/
                            └── 📁 infrastructure/
                                ├── 📁 config/
                                │   └── 📄 KafkaConsumerConfig.java
                                └── 📁 messaging/
```
**3. Programmatic Telemetry Consumer Resiliency (infrastructure/config/KafkaConsumerConfig.java)**

```
// java

package com.payment.platform.analytics.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.DeadLetterPublishingRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.util.backoff.FixedBackOff;

@Configuration
public class KafkaConsumerConfig {

    @Bean
    public DefaultErrorHandler errorHandler(KafkaTemplate<Object, Object> template) {
        DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template);
        DefaultErrorHandler errorHandler = new DefaultErrorHandler(recoverer, new FixedBackOff(1000L, 3L));
        errorHandler.setCommitRecovered(true);
        return errorHandler;
    }
}
```

## Section 10: Automated Balancing Core (reconciliation-service)
**1. Purpose & Scope**: Operates on port 8089 as an automated system audit checker. It continuously consumes terminal transaction logs and triggers automated batch cross-referencing against external banking settlement records to track variance lines and isolate balancing discrepancies.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\reconciliation-service\
   * Directory Structure:
```
📁 reconciliation-service/
├── 📄 pom.xml
└── 📁 src/
    └── 📁 main/
        └── 📁 java/
            └── 📁 com/
                └── 📁 payment/
                    └── 📁 platform/
                        └── 📁 reconciliation/
                            ├── 📁 domain/
                            └── 📁 infrastructure/
                                ├── 📁 config/
                                │   └── 📄 KafkaConsumerConfig.java
                                └── 📁 messaging/
```

**3. Inbound Audit Stream Error Boundary (infrastructure/config/KafkaConsumerConfig.java)**

```
// java

package com.payment.platform.reconciliation.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.DeadLetterPublishingRecoverer;
import org.springframework.kafka.listener.DefaultErrorHandler;
import org.springframework.util.backoff.FixedBackOff;

@Configuration
public class KafkaConsumerConfig {

    @Bean
    public DefaultErrorHandler errorHandler(KafkaTemplate<Object, Object> template) {
        DeadLetterPublishingRecoverer recoverer = new DeadLetterPublishingRecoverer(template);
        DefaultErrorHandler errorHandler = new DefaultErrorHandler(recoverer, new FixedBackOff(1000L, 3L));
        errorHandler.setCommitRecovered(true);
        return errorHandler;
    }
}
```

## Section 11: Environment Automation Hub (payment-infrastructure)
**1. Purpose & Scope**: This repository operates on port 8090 as your centralized operational automation workspace hub. It isolates system topology definitions from business application logic, containing your master local docker orchestration configurations and pre-deployment health check utilities.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\payment-infrastructure\
   * Directory Structure:
```
📁 payment-infrastructure/
├── 📄 pom.xml
├── 📄 docker-compose.yml
└── 📁 src/
    └── 📁 main/
        ├── 📁 java/
        └── 📁 resources/
            └── 📄 application.yml
```

**3. Master Distributed Sandbox Topology Grid (docker-compose.yml)**

```
version: '3.8'

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
    ports:
      - "2181:2181"

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092,PLAINTEXT_INTERNAL://kafka:29092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1

  redis:
    image: redis:7.2-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes

  payment-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: platform_user
      POSTGRES_PASSWORD: secure_password_99
      POSTGRES_DB: payment_ledger_core
    ports:
      - "5432:5432"

  ledger-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: platform_user
      POSTGRES_PASSWORD: secure_password_99
      POSTGRES_DB: bookkeeping_audit_core
    ports:
      - "5433:5432"

  analytics-db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: platform_user
      POSTGRES_PASSWORD: secure_password_99
      POSTGRES_DB: metrics_projection_core
    ports:
      - "5434:5432"
```

## Section 12: Merchant Dashboard Frontend Portal (payment-ui)
**1. Purpose & Scope**: Serves as the central administration reporting portal and telemetry dashboard running on local port 3000. Built using React and TypeScript, it communicates non-blockingly with the API perimeter gateway and tracks real-time settlement volumes.

**2. Physical Layout Tree Matrix**
   * Target Workspace Path: \payment-platform\payment-ui\
   * Directory Structure:
```
📁 payment-ui/
├── 📄 package.json
├── 📄 vite.config.ts
├── 📄 .gitignore
└── 📁 src/
    ├── 📁 components/
    └── 📁 services/
        └── 📄 api.ts
```
## Section 13: Corporate Cloud DevOps & Build Orchestration
**1. Standard Multi-Stage Container Profile Template (Dockerfile)**

```
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build-engine
WORKDIR /workspace/source
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

FROM eclipse-temurin:21-jre-alpine AS runtime-engine
WORKDIR /platform/runtime
RUN addgroup -S platformgroup && adduser -S platformuser -G platformgroup
USER platformuser
COPY --from=build-engine /workspace/source/target/*.jar platform-app.jar
ENV JAVA_OPTS="-XX:+UseG1GC -XX:+ExitOnOutOfMemoryError -Xms512m -Xmx2g"
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar platform-app.jar"]
```

**2. Multi-Stage Continuous Integration Deployment Automation Engine (azure-pipelines.yml)**

```
trigger:
  batch: true
  branches:
    include: [main]

pool:
  vmImage: 'ubuntu-latest'

variables:
  azureSubscription: 'sc-payment-platform-service-connection'
  azureContainerRegistry: 'acrpaymentplatformprod.azurecr.io'   
  imageRepository: '$(Build.Repository.Name)'                 
  tag: '$(Build.BuildId)'                                      

stages:
  - stage: BuildAndPackage
    jobs:
      - job: BuildCode
        steps:
          - task: Maven@4
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'clean test'
          - task: Docker@2
            inputs:
              containerRegistry: '$(azureSubscription)'
              repository: '$(imageRepository)'
              command: 'buildAndPush'
              Dockerfile: '**/Dockerfile'
              tags: |
                $(tag)
                latest
```