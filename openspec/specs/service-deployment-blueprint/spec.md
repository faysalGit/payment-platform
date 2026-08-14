## 1. Local Microservice Folder Matrix
To ensure loose coupling and independent deployability across your platform, every distinct application repository (such as payment-api-gateway and payment-service) must host its own explicit copy of its containerization, build pipeline, and routing manifests. Ensure your local files are placed exactly according to this directory tree layout:

```
📁 payment-service/ (Or payment-api-gateway/)
│
├── 📄 pom.xml                      <-- Core Build Configuration
├── 📄 Dockerfile                   <-- Optimized Host-Compiled Runtime Containerization
├── 📄 azure-pipelines.yml          <-- Azure DevOps Multi-Stage Pipeline Automation Script
│
├── 📁 k8s/
│   └── 📄 deployment.yml           <-- Target Azure Kubernetes Service Manifest Topology
│
└── 📁 src/
    └── main/
        └── resources/
            └── application.yml     <-- Local Runtime Properties Matrix
```

## 2. Verified Microservice Dockerfile Template
Save this optimized, single-stage configuration script as Dockerfile at the absolute root directory of your individual service folder. This structure leverages the compiled outputs from your Azure DevOps environment, completely removing private submodule .jar classpath errors by relying on the pipeline agent's compilation artifact.

```
# =========================================================================
# Lightweight Java 21 Non-Root Container Execution Runtime Environment
# =========================================================================
FROM eclipse-temurin:21-jre-alpine AS runtime-engine
WORKDIR /platform/runtime

# Establish a highly restricted, non-root application system execution group
RUN addgroup -S platformgroup && adduser -S platformuser -G platformgroup
USER platformuser

# Copy the fat executable jar compiled by the Azure DevOps Pipeline host agent
COPY target/*.jar platform-service.jar

# Enforce secure network socket bindings and optimize memory expansion footprints
ENV JAVA_OPTS="-XX:+UseG1GC -XX:+ExitOnOutOfMemoryError -Xms512m -Xmx2g"

# Expose standard gateway, routing, and processing microservice ports
EXPOSE 8080 8081 8082

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar platform-service.jar"]
```

## 3. Verified azure-pipelines.yml Automation Engine
Save this automation script as azure-pipelines.yml at the absolute root directory of your individual service folder. Ensure you alter the pom.xml target flags to execute a standard package routine so that the resulting .jar file is visible to the Dockerfile copy task.

```
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
  # Stage 1: Continuous Integration, Code Packaging & Containerization Loop
  # =========================================================================
  - stage: BuildAndPackage
    displayName: 'CI Phase: Compile and Containerize'
    jobs:
      - job: BuildCode
        displayName: 'Execute Verification and Push Image'
        steps:
          # 1. Compile Code, Run Tests, and Output Fat Executable JAR onto Host Agent
          - task: Maven@4
            displayName: 'Compile, Test and Package Application Artifact'
            inputs:
              mavenPomFile: 'pom.xml'
              goals: 'clean package' # Generates the required target/*.jar asset on host filesystem
              options: '-B -DskipTests=false'
              publishJUnitResults: true
              testResultsFiles: '**/surefire-reports/TEST-*.xml'

          # 2. Build and Push the Production Image directly using host context target/*.jar file
          - task: Docker@2
            displayName: 'Build and Publish Image to ACR'
            inputs:
              containerRegistry: '$(azureSubscription)'
              repository: '$(imageRepository)'
              command: 'buildAndPush'
              Dockerfile: 'Dockerfile' # Point directly to root single-stage Dockerfile
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
                    containers: '$(azureContainerRegistry)/$(imageRepository):$(tag)'
```

## 4. Verified Kubernetes Cluster Manifest (k8s/deployment.yml)
Save this resource manifest as deployment.yml inside a folder named k8s located at the absolute root directory of your individual service workspace (e.g., payment-service/k8s/deployment.yml). This manifest handles pod lifecycle scaling, compute resource limits, configuration injection flags, and network service load-balancing mappings.

```
# =========================================================================
# Application Workload Pod Replica Specification
# =========================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service-deployment
  namespace: default
  labels:
    app: payment-service
    tier: backend
spec:
  replicas: 2 # Maintains high-availability double-pod redundancy nodes across cluster zones
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1       # Spins up exactly one new pod wrapper before pruning old containers
      maxUnavailable: 0 # Enforces zero application downtime windows during pipeline rollouts
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
    spec:
      # Restricts containers from executing tasks under elevated root OS host privileges
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        fsGroup: 10001
      containers:
        - name: payment-service-app
          image: acrpaymentplatformprod.azurecr.io/payment-service:latest # Dynamic pipeline injection target
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8081 # Active localized network socket profile container binding
              name: http-web
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: "prod"
            # Injects the target Azure Key Vault URL so the service can resolve cloud secrets at boot time
            - name: SPRING_CLOUD_AZURE_KEYVAULT_SECRET_ENDPOINT
              value: "https://azure.net"
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "1024Mi" # Caps resource spikes to safeguard cluster node stability bounds
              cpu: "500m"
          # Monitors container startup initialization curves before executing health lookups
          startupProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8081
            failureThreshold: 30
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8081
            initialDelaySeconds: 10
            periodSeconds: 15
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: 8081
            initialDelaySeconds: 10
            periodSeconds: 15

---
# =========================================================================
# Internal Network Cluster Service Load Balancer
# =========================================================================
apiVersion: v1
kind: Service
metadata:
  name: payment-service-svc
  namespace: default
  labels:
    app: payment-service
spec:
  type: ClusterIP # Restricts network exposure exclusively inside the private cluster network mesh
  ports:
    - port: 8081
      targetPort: 8081
      protocol: TCP
      name: http-routing
  selector:
    app: payment-service
```

## Section 5: Global Multi-Module GitIgnore and Untracking Configurations

1. Root Repository .gitignore SpecificationSave this exact block directly into your absolute root file location path: payment-platform/.gitignore

```
# =========================================================================
# OpenSpec Master Platform Root Repository .gitignore
# =========================================================================
# Enforces the "Specification-Only" orchestration pattern by preventing 
# the parent plane from absorbing standalone decoupled sub-repositories.

# Ignore all 12 operational microservice sub-repositories
/payment-api-gateway/
/payment-ui/
/payment-service/
/fraud-service/
/payment-worker/
/provider-router-service/
/notification-service/
/ledger-service/
/reconciliation-service/
/analytics-service/
/shared-contracts/
/payment-infrastructure/

# =========================================================================
# AI Autonomous Agent Transient & State Management Directories
# =========================================================================
.agents/
.claude/
.github/
.cline/
.roo/
bin/
obj/

# =========================================================================
# Local IDE Project Metadata Registries
# =========================================================================
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.swp
*.log

# =========================================================================
# Global Compilations and Runtime Execution Binaries
# =========================================================================
target/
**/target/
*.class
*.jar
*.war
*.ear

# =========================================================================
# Core Operating System Transient Metadata Blocks
# =========================================================================
.DS_Store
.DS_Store?
._*
Thumbs.db
ehthumbs.db
Desktop.ini
```

## 2. Universal Submodule Microservice .gitignore Specification
Save this exact block inside the absolute root folder of every single standalone microservice (e.g., payment-service/.gitignore, payment-api-gateway/.gitignore, notification-service/.gitignore):

```
# =========================================================================
# Microservice Module Localized .gitignore Baseline
# =========================================================================

# Ignore all local compiled binary output targets completely
target/
*.class
*.jar
*.war
*.ear

# Ignore AI background automation trackers and logs locally
.agents/
.claude/
.github/
.cline/
.roo/
*.log

# Ignore IDE specific parameters
.idea/
.vscode/
*.swp
```

## 3. Multi-Module Target and Agent Directory Cache-Purge Automation Sequence
Run these localized terminal scripts sequentially across your sub-repository folders to build all repositories in your local

```
powershell

# Core Contract Models & Libraries
cd E:\Projects\payment-platform\shared-contracts; mvn clean install

# Synchronous REST API Ingestion Layers & Gateways
cd E:\Projects\payment-platform\payment-api-gateway; mvn clean compile -o
cd E:\Projects\payment-platform\payment-service; mvn clean compile -o
cd E:\Projects\payment-platform\provider-router-service; mvn clean compile -o

# Asynchronous Kafka Consumer Processing Daemons
cd E:\Projects\payment-platform\fraud-service; mvn clean compile -o
cd E:\Projects\payment-platform\payment-worker; mvn clean compile -o
cd E:\Projects\payment-platform\notification-service; mvn clean compile -o
cd E:\Projects\payment-platform\ledger-service; mvn clean compile -o
cd E:\Projects\payment-platform\analytics-service; mvn clean compile -o
cd E:\Projects\payment-platform\reconciliation-service; mvn clean compile -o

# Support Environments & Orchestration Hub
cd E:\Projects\payment-platform\payment-infrastructure; mvn clean compile -o

```

## 4. Multi-Module Target and Agent Directory Cache-Purge Automation Sequence for git
Run these localized terminal scripts sequentially across your sub-repository folders to build all repositories in your local

# 1. Synchronize shared-contracts
cd E:\Projects\payment-platform\shared-contracts
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "chore: align payment and fraud core record payload schemas"; git push origin main }

# 2. Synchronize payment-api-gateway
cd E:\Projects\payment-platform\payment-api-gateway
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "infra: establish edge perimeter proxy routing and security rules"; git push origin main }

# 3. Synchronize payment-service
cd E:\Projects\payment-platform\payment-service
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "feat: establish global exception handling advice wall and topic configs"; git push origin main }

# 4. Synchronize fraud-service
cd E:\Projects\payment-platform\fraud-service
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "feat: implement consumer error handler and reposition messaging packages"; git push origin main }

# 5. Synchronize payment-worker
cd E:\Projects\payment-platform\payment-worker
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "feat: configure worker async consumer default error handling limits"; git push origin main }

# 6. Synchronize provider-router-service
cd E:\Projects\payment-platform\provider-router-service
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "feat: add localized WebClient response exception translations"; git push origin main }

# 7. Synchronize notification-service
cd E:\Projects\payment-platform\notification-service
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "feat: arm notification consumer with fallback dead letter configuration"; git push origin main }

# 8. Synchronize ledger-service
cd E:\Projects\payment-platform\ledger-service
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "feat: secure bookkeeping consumers with automatic DLT recovery"; git push origin main }

# 9. Synchronize analytics-service
cd E:\Projects\payment-platform\analytics-service
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "feat: establish global stream processing error handler boundary"; git push origin main }

# 10. Synchronize reconciliation-service
cd E:\Projects\payment-platform\reconciliation-service
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "feat: apply programmatic retry policies to audit matching consumers"; git push origin main }

# 11. Synchronize payment-infrastructure
cd E:\Projects\payment-platform\payment-infrastructure
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "infra: formalize central compose topologies and pre-flight validation rules"; git push origin main }

# 12. Synchronize payment-ui
cd E:\Projects\payment-platform\payment-ui
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "chore: apply clean .gitignore filters and resolve dashboard styling typos"; git push origin main }

# 13. Synchronize Master Parent Orchestration Root Repository (payment-platform)
cd E:\Projects\payment-platform
git add .
git diff-index --quiet HEAD --
if ($LASTEXITCODE -ne 0) { git commit -m "chore: synchronize root workspace tracking hashes for all 12 submodules"; git push origin main }
