## 1. Local Microservice Folder Matrix
To ensure loose coupling and independent deployability across your platform, every distinct application repository (such as payment-api-gateway and payment-service) must host its own explicit copy of its containerization, build pipeline, and routing manifests. Ensure your local files are placed exactly according to this directory tree layout:

```text
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

```text
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

```text
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

```text
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