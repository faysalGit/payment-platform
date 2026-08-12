# CI/CD Architecture & Azure Deployment Specifications

## 1. Global CI/CD Architecture & Azure Invariants
To preserve the multi-repository microservices boundaries while achieving zero-trust security, the platform decouples source code storage from deployment compute. Code lives on GitHub, while the compilation, testing, containerization, and orchestration execution occur entirely within Azure DevOps (dev.azure.com).

### 1.1 Architectural Invariants
- **Container Isolation**: Every microservice compile loop must result in an independent, immutable Docker container image using a multi-stage architecture.
- **Registry Security**: All images are stored in a private Azure Container Registry (ACR) with automated vulnerability analysis.
- **Orchestration Mesh**: Runtime lifecycles are managed inside an Azure Kubernetes Service (AKS) cluster utilizing native manifests.
- **Zero GitHub Credentials**: No Azure Service Principals or production infrastructure secrets are permitted within GitHub repository settings. Authentication is handled entirely via Azure DevOps Service Connections.

## 2. Standardized Multi-Stage Dockerfile
Every microservice repository requiring a Java runtime environment must include a Dockerfile at its root directory. It mandates a multi-stage compilation pattern to eliminate build-time tools from the final container layer footprint.

```dockerfile
# Stage 1: Compile and build package assets
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY . .
RUN ./mvnw clean package -DskipTests

# Stage 2: Minimalist production runtime environment
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S paymentgroup && adduser -S paymentuser -G paymentgroup
USER paymentuser
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## 3. Azure Pipelines Automated CI/CD Configuration
This build sequence must be saved as azure-pipelines.yml at the root directory of each codebase repository. It hooks natively into Azure DevOps to run verification jobs on hosted Linux agents.

```yaml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: "ubuntu-latest"

variables:
  acrServiceConnection: "cr-payment-registry-link"
  aksServiceConnection: "aks-payment-cluster-link"
  acrLoginServer: "crpaymentplatformprod.azurecr.io"
  imageRepository: "payment-service"
  kubernetesNamespace: "payment-routing-mesh"
  tag: "$(Build.BuildId)"

stages:
  - stage: Build
    displayName: "Build and Containerize"
    jobs:
      - job: BuildAndPush
        steps:
          - task: Maven@4
            inputs:
              mavenPomFile: "pom.xml"
              goals: "clean test"
              publishJUnitResults: true
              jdkVersionOption: "1.21"
          - task: Docker@2
            inputs:
              containerRegistry: "$(acrServiceConnection)"
              repository: "$(imageRepository)"
              command: "buildAndPush"
              Dockerfile: "**/Dockerfile"
              tags: |
                $(tag)
                latest

  - stage: Deploy
    displayName: "Deploy to Infrastructure Mesh"
    dependsOn: Build
    condition: succeeded()
    jobs:
      - job: DeployToAKS
        steps:
          - task: KubernetesManifest@1
            inputs:
              action: "bake"
              renderType: "helm"
              manifests: "k8s/deployment.yml"
          - task: KubernetesManifest@1
            inputs:
              action: "deploy"
              kubernetesServiceConnection: "$(aksServiceConnection)"
              namespace: "$(kubernetesNamespace)"
              manifests: |
                k8s/deployment.yml
                k8s/service.yml
              containers: |
                $(acrLoginServer)/$(imageRepository):$(tag)
```

## 4. Azure Kubernetes Service (AKS) Manifest Architecture
Every service deployment must define its container properties inside a k8s/ configuration directory structure using strict resource allocations.

### 4.1 Deployment Configuration (k8s/deployment.yml)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service-deployment
  namespace: payment-routing-mesh
spec:
  replicas: 3
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
    spec:
      containers:
      - name: payment-service
        image: crpaymentplatformprod.azurecr.io/payment-service:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: "1"
            memory: 512Mi
          requests:
            cpu: "500m"
            memory: 256Mi
```

### 4.2 Service Layer Configuration (k8s/service.yml)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: payment-service-internal
  namespace: payment-routing-mesh
spec:
  type: ClusterIP
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    app: payment-service
```
