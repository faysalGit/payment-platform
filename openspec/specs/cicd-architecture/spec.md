# CI/CD Architecture & Azure Deployment Specifications

## 1. Core Engineering Invariants
This document establishes the official enterprise specification for the platform's continuous integration and continuous deployment (CI/CD) boundaries. All 12 sub-service repositories must natively consume these exact templates to ensure security, compliance, and predictable scaling within the cloud infrastructure.

## System Rules
* Zero Secret Leakage: No private service accounts, raw passwords, or Azure Service Principal client keys may be physically written or stored within any GitHub repository branches. All authorization loops must run exclusively inside Azure DevOps using native Service Connections.
* Isolated Environment Contexts: Deployment configurations must be fully parameter driven. Hard-coded internal environment properties are strictly banned.
* Java 21 Alignment: All compilation and execution base images must be strictly locked to official enterprise Java 21 footprints. Traditional legacy runtimes or Lombok-dependent plugin overrides are prohibited.

## 2. Multi-Stage Java 21 Containerization Blueprint
Every individual microservice repository (such as payment-api-gateway and payment-service) must maintain this exact Dockerfile at its absolute root folder path. It leverages an optimized multi-stage compilation loop to ensure build security and minimal image footprint sizes.

```text
# =========================================================================
# Phase 1: High-Performance Distributed Build Context
# =========================================================================
FROM maven:3.9.6-eclipse-temurin-21-alpine AS build-engine
WORKDIR /workspace/source

# Warm the local package cache layers by copying module configurations independently
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the pre-compiled local library dependencies and source artifacts
COPY src ./src

# Execute an optimized production build discarding transient testing footprints
RUN mvn clean package -DskipTests -B

# =========================================================================
# Phase 2: Ultra-Lightweight Secure Runtime Context
# =========================================================================
FROM eclipse-temurin:21-jre-alpine AS runtime-engine
WORKDIR /platform/runtime

# Establish a highly restricted, non-root application system execution group
RUN addgroup -S platformgroup && adduser -S platformuser -G platformgroup
USER platformuser

# Copy the optimized fat executable jar directly from the build context layer
COPY --from=build-engine /workspace/source/target/*.jar platform-service.jar

# Enforce secure network socket bindings and optimize memory expansion footprints
ENV JAVA_OPTS="-XX:+UseG1GC -XX:+ExitOnOutOfMemoryError -Xms512m -Xmx2g"
EXPOSE 8080 8081 8082

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar platform-service.jar"]
```

## 3. The Unified Azure DevOps Pipeline Engine
Save this template configuration exactly as azure-pipelines.yml at the root of your microservice repository folders. It establishes a multi-stage orchestration system that automatically mirrors changes from your public GitHub repository to run automated tasks inside Azure DevOps.

``` text
trigger:
  batch: true
  branches:
    include:
      - main # Executes automated build validations immediately on main branch merges

pool:
  vmImage: 'ubuntu-latest' # Utilizes managed, clean Linux virtualization runners

variables:
  # Centralized naming tokens mapping to your secure Azure Cloud architecture infrastructure
  azureSubscription: 'sc-payment-platform-service-connection' # The secure connection name inside dev.azure.com
  azureContainerRegistry: 'acrpaymentplatformprod.azurecr.io'   # Your private cloud image repository domain
  aksResourceGroup: 'rg-payment-platform-prod'                # Target Azure Resource Group control block
  aksClusterName: 'aks-payment-cluster-prod'                  # Target production Kubernetes gateway cluster
  imageRepository: '$(Build.Repository.Name)'                 # Dynamically derives the active service folder name
  tag: '$(Build.BuildId)'                                      # Maps a unique incrementing version token

stages:
  # =========================================================================
  # Stage 1: Continuous Integration & Containerization Loop
  # =========================================================================
  - stage: BuildAndPackage
    displayName: 'CI Phase: Compile and Containerize'
    jobs:
      - job: BuildCode
        displayName: 'Execute Verification and Push Image'
        steps:
          # 1. Initialize System Versioning and Run Unit Test Coverages
          - task: Maven@4
            displayName: 'Execute Maven Test Suites'
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'clean test'
              options: '-B'
              publishJUnitResults: true
              testResultsFiles: '**/surefire-reports/TEST-*.xml'

          # 2. Build and Push the Production Image directly to the Azure Container Registry
          - task: Docker@2
            displayName: 'Build and Publish Image to ACR'
            inputs:
              containerRegistry: '$(azureSubscription)'
              repository: '$(imageRepository)'
              command: 'buildAndPush'
              Dockerfile: '**/Dockerfile'
              tags: |
                $(tag)
                latest

  # =========================================================================
  # Stage 2: Continuous Deployment & Kubernetes Orchestration Loop
  # =========================================================================
  - stage: DeployToProduction
    displayName: 'CD Phase: Rolling Blue-Green Cluster Deployment'
    dependsOn: BuildAndPackage
    condition: succeeded() # Restricts deployment iterations if any code testing failures occur
    jobs:
      - deployment: DeployClusterResources
        displayName: 'Execute Kubernetes Manifest Migrations'
        environment: 'Production-Mesh' # Maps directly to approval and gating dashboard vectors
        strategy:
          runOnce:
            deploy:
              steps:
                # 1. Securely bind the active pipeline instance to the target AKS gateway
                - task: KubernetesManifest@1
                  displayName: 'Initialize Azure Kubernetes Cluster Context'
                  inputs:
                    action: 'bake'
                    azureSubscriptionConnection: '$(azureSubscription)'
                    azureResourceGroup: '$(aksResourceGroup)'
                    kubernetesCluster: '$(aksClusterName)'
                    manifests: '**/k8s/*.yml'
                    imageToConsider: '$(azureContainerRegistry)/$(imageRepository):$(tag)'

                # 2. Execute a non-blocking rolling update across the target deployment pods
                - task: KubernetesManifest@1
                  displayName: 'Deploy Manifest Frameworks to AKS Mesh'
                  inputs:
                    action: 'deploy'
                    azureSubscriptionConnection: '$(azureSubscription)'
                    azureResourceGroup: '$(aksResourceGroup)'
                    kubernetesCluster: '$(aksClusterName)'
                    manifests: '**/k8s/*.yml'
                    containers: '$(azureContainerRegistry)/$(imageRepository):$(tag)'
```

## 3.1 Library Azure DevOps Pipeline Engine (shared-contracts)
Save this configuration block exactly as azure-pipelines.yml at the absolute root of your shared-contracts repository folder. It compiles your Java 21 Records, runs the contract validation test suite, authenticates with your private DevOps artifact feed, and publishes the compiled .jar libraries so downstream microservice pipelines can consume them.

```text 
trigger:
  batch: true
  branches:
    include:
      - main # Triggers compilation and publication loops on direct main branch merges

pool:
  vmImage: 'ubuntu-latest' # Managed Linux virtualization runner

variables:
  # The name of your private Azure DevOps Maven feed artifact repository
  targetMavenFeed: 'payment-platform-artifacts' 

stages:
  # =========================================================================
  # Stage 1: Continuous Integration & Artifact Publication Loop
  # =========================================================================
  - stage: BuildAndPublish
    displayName: 'Library CI/CD: Compile, Test, and Publish'
    jobs:
      - job: PublishLibrary
        displayName: 'Build Jar and Deploy to Azure Artifacts'
        steps:
          # 1. Initialize System Versioning and Run Unit Test Coverages
          - task: Maven@4
            displayName: 'Execute Contract Validation Tests'
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'clean test'
              options: '-B'
              publishJUnitResults: true
              testResultsFiles: '**/surefire-reports/TEST-*.xml'

          # 2. Securely bind the pipeline session to your private Azure DevOps Maven feed
          - task: MavenAuthenticate@0
            displayName: 'Maven Authenticate to Azure Artifacts Feed'
            inputs:
              artifactsFeeds: '$(targetMavenFeed)'

          # 3. Compile, wrap into jar assets, and deploy directly to your private feed registry
          - task: Maven@4
            displayName: 'Deploy Jar Artifacts to private Azure Feed'
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'deploy'
              options: '-DskipTests -B' # Tests already executed in Step 1
```

## 4. Kubernetes Manifest Orchestration Topologies
Every sub-service must organize its cluster descriptor configurations inside a folder named k8s/ sitting at its repository root. Save this configuration block as k8s/deployment.yml to manage pod lifecycles and horizontal routing scales reactively.

```text
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service-deployment
  namespace: payment-platform-mesh
  labels:
    app: payment-service
spec:
  replicas: 3 # Establishes a highly available 3-node localized failover footprint
  strategy:
    type: RollingUpdate # Executes clean, zero-downtime application version switches
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
    spec:
      containers:
        - name: service-runtime
          image: acrpaymentplatformprod.azurecr.io/payment-service:latest
          ports:
            - containerPort: 8081
          # Enforce rigid compute ceilings to protect sibling nodes against memory bleedouts
          resources:
            limits:
              cpu: "1000m"
              memory: "2Gi"
            requests:
              cpu: "500m"
              memory: "512Mi"
          # Automated platform diagnostic hooks checking execution health states continuously
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: 8081
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: 8081
            initialDelaySeconds: 15
            periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: payment-service-svc
  namespace: payment-platform-mesh
spec:
  type: ClusterIP # Restricts exposure, keeping traffic fully contained within the secure internal mesh network
  ports:
    - port: 8081
      targetPort: 8081
  selector:
    app: payment-service
```

## 5. API Gateway Routing Matrix (application.yml)
Save this configuration block exactly as application.yml inside your local gateway module folder at the src/main/resources/ path. It binds your custom reactive security parameters and EdgeTrafficManagementFilter tracking rules directly to your Kubernetes internal cluster routing mesh.

```text
server:
  port: 8080 # Perimeter edge listener container execution port binding hook

spring:
  application:
    name: payment-api-gateway
  
  cloud:
    gateway:
      # Establish global Cross-Origin Resource Sharing rules for browser client applications
      globalcors:
        cors-configurations:
          '[/**]':
            allowedOrigins: "*"
            allowedMethods:
              - GET
              - POST
              - PUT
              - DELETE
              - OPTIONS
            allowedHeaders: "*"
            exposedHeaders:
              - "X-Correlation-ID" # Ensure web browser clients can capture tracing metadata tokens
      
      # Core Route Matrices: Mapping perimeter URLs to decoupled target services
      routes:
        - id: payment-service-route
          uri: http://payment-service-svc:8081 # Routes internally to the target Kubernetes ClusterIP DNS
          predicates:
            - Path=/api/v1/payments/**
          filters:
            - StripPrefix=0 # Maintain exact URI naming conventions down to the target microservice

        - id: fraud-service-route
          uri: http://fraud-service-svc:8082 # Routes internally to the fraud evaluation pod meshes
          predicates:
            - Path=/api/v1/fraud/**
          filters:
            - StripPrefix=0

  # Perimeter Access Validation: Delegate security checks to your Azure/OAuth Server
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://microsoftonline.com
          jwk-set-uri: https://microsoftonline.com

# Comprehensive Microservice Diagnostics & Telemetry Matrices
management:
  endpoints:
    web:
      exposure:
        include: health, info, metrics, prometheus
  endpoint:
    health:
      show-details: always
```
## Template A: Standard Backend Microservice Layout (e.g., payment-service)
Apply this structure inside your standalone application repositories. The configuration properties match standard backend business logic requirements.

```text
📁 payment-service/                  <-- Your microservice root directory folder
│
├── 📄 pom.xml                       <-- Core Maven dependency mapping configuration
├── 📄 Dockerfile                    <-- [SAVE HERE] Multi-stage compilation script
├── 📄 azure-pipelines.yml          <-- [SAVE HERE] Azure DevOps automation engine script
│
├── 📁 k8s/                          <-- Create this folder at the root level
│   └── 📄 deployment.yml            <-- [SAVE HERE] Kubernetes manifest topology descriptors
│
└── 📁 src/
    └── 📁 main/
        ├── 📁 java/                 <-- Contains your com.payment.platform packages
        └── 📁 resources/            <-- Create this folder if missing under main/
            └── 📄 application.yml   <-- [SAVE HERE] Microservice-specific port/DB configs
```

## Template B: Edge Infrastructure Layout (payment-api-gateway)
Apply this structure inside your perimeter edge routing repository. The configuration properties route incoming public network targets down to internal Kubernetes ClusterIP services.

```text
📁 payment-api-gateway/              <-- Your perimeter edge root directory folder
│
├── 📄 pom.xml                       <-- Gateway Maven build file with WebFlux dependencies
├── 📄 Dockerfile                    <-- [SAVE HERE] Multi-stage compilation script
├── 📄 azure-pipelines.yml          <-- [SAVE HERE] Azure DevOps automation engine script
│
├── 📁 k8s/                          <-- Create this folder at the root level
│   └── 📄 deployment.yml            <-- [SAVE HERE] Kubernetes manifest topology descriptors
│
└── 📁 src/
    └── 📁 main/
        ├── 📁 java/                 <-- Contains your gateway filters and security classes
        └── 📁 resources/            <-- Create this folder if missing under main/
            └── 📄 application.yml   <-- [SAVE HERE] The Edge Routing property matrix script
```