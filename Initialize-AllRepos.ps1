# Initialize-AllRepos.ps1

<#
.SYNOPSIS
    Automates the initialization, initial commit, and remote push for all 12 payment platform microservices.
.DESCRIPTION
    This script traverses or creates the 12 specified microservice folders under the root 'payment-platform' directory,
    initializes Git independently for each subfolder, inserts a standardized baseline README.md, and pushes the code
    to its corresponding pre-created remote repository on GitHub.
.PARAMETER GitHubUsername
    The GitHub account username where the 12 target repositories were created.
.EXAMPLE
    .\Initialize-AllRepos.ps1 -GitHubUsername "your-github-handle"
#>

[CmdletBinding()]param (
    [Parameter(Mandatory = $true, HelpMessage = "Please enter your GitHub account username")]
    [string]$GitHubUsername
)


# Explicit definition of the 12 target repositories in structural sequence
$repositories = @(
    "payment-api-gateway",
    "payment-ui",
    "payment-service",
    "fraud-service",
    "payment-worker",
    "provider-router-service",
    "notification-service",
    "ledger-service",
    "reconciliation-service",
    "analytics-service",
    "shared-contracts",
    "payment-infrastructure"
)
# Store the root execution path to ensure accurate directory traversal tracking
$rootDirectory = Get-Location


Write-Host "=====================================================================" -ForegroundColor Green
Write-Host " STARTING AUTOMATED MICROSERVICE GIT INITIALIZATION AND DEPLOYMENT" -ForegroundColor Green
Write-Host " Target Account: GitHub.com/$GitHubUsername" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Green
foreach ($repoName in $repositories) {
    Write-Host "`nProcessing repository: [$repoName]..." -ForegroundColor Yellow
    
    # 1. Enforce local folder presence
    if (-not (Test-Path -Path $repoName)) {
        Write-Host " -> Folder absent locally. Creating directory: /$repoName" -ForegroundColor Gray
        New-Item -ItemType Directory -Name $repoName | Out-Null
    }
    
    # Navigate cleanly into the child repository boundary folder
    Set-Location -Path $repoName
    
    # 2. Prevent accidental corruption of an already initialized Git workspace
    if (Test-Path -Path ".git") {

        Write-Host " [WARNING] .git history already discovered inside /$repoName. Skipping execution loops to prevent disruption." -ForegroundColor DarkYellow
        Set-Location -Path $rootDirectory
        continue
    }
    
    try {
        Write-Host " -> Initializing independent Git repository core..." -ForegroundColor Gray
        git init --quiet
        
        # 3. Inject a highly descriptive, professional baseline README structure
        Write-Host " -> Generating structural baseline documentation..." -ForegroundColor Gray
        
        # Using a standard array of strings instead of a here-string to avoid parsing sensitivity.
        $readmeContent = @(
            "# $repoName",
            "",
            "This repository forms part of the distributed High-Volume Payment Processing Platform ecosystem.",
            "",
            "## Architectural Classification",

            "- **Domain Scope**: $repoName",
            "- **Ecosystem Grounding**: Clean Architecture, Java 21+, Spring Boot 3.x",
            "- **Configuration Authority**: Governed centrally via the openspec/ core control plane.",
            "",
            "## Development Constraints",
            "1. Codebases must comply with the engineering invariants outlined within openspec/project.md.",
            "2. Do not introduce synchronous dependencies on sibling service runtimes."
        )

        Set-Content -Path "README.md" -Value $readmeContent -Encoding UTF8
        
        # 4. Standard Stage, Commit, and Branch operations
        Write-Host " -> Staging and committing baseline configuration units..." -ForegroundColor Gray
        git add README.md
        git commit -m "init: baseline repository architecture setup" --quiet
        git branch -M main
        
        # 5. Build dynamic remote URL pathing matching the GitHub naming schema
        $remoteUrl = "https://github.com/$GitHubUsername/$repoName.git"

        Write-Host " -> Connecting tracking link to remote destination: $remoteUrl" -ForegroundColor Gray
        git remote add origin $remoteUrl
        
        # 6. Execute out-of-process push action securely
        Write-Host " -> Dispatching code upstream to origin/main..." -ForegroundColor Cyan
        git push -u origin main --quiet
        
        Write-Host " [SUCCESS] Repository [$repoName] successfully deployed online." -ForegroundColor Green
        
    } catch {
        Write-Error "Failed to process repository execution pipeline for target folder: $repoName. Exception message: $_"
    } finally {
        # Securely return back up to the master parent scope before next loop iteration
        Set-Location -Path $rootDirectory
    }
}

Write-Host "`n=====================================================================" -ForegroundColor Green
Write-Host " ALL REPOSITORIES INITIALIZED, COMMITTED, AND SYNCHRONIZED CLEANLY!" -ForegroundColor Green

Write-Host "=====================================================================" -ForegroundColor Green


