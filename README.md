# 🚀 DevOps CI/CD Pipeline Demo

[

![CI/CD Pipeline](https://github.com/vishwa-git04/Devops-ci-cd-demo/actions/workflows/ci-cd.yml/badge.svg)

](https://github.com/vishwa-git04/Devops-ci-cd-demo/actions/workflows/ci-cd.yml)


![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)




![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)




![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=flat-square&logo=jenkins&logoColor=white)




![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white)




![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazonaws&logoColor=white)



A production-grade CI/CD pipeline implementation demonstrating real-world DevOps practices — automated build, test, security scan, and multi-environment deployment to AWS EKS.

---

## 📋 Table of Contents

- [Architecture](#-architecture)
- [Pipeline Stages](#-pipeline-stages)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [How It Works](#-how-it-works)
- [Environment Setup](#-environment-setup)
- [Key Features](#-key-features)

---

## 🏗️ Architecture
Developer → Git Push → GitHub
│
▼
┌───────────────┐
│  GitHub       │
│  Actions      │
└───────┬───────┘
│
┌───────────────┼───────────────┐
▼               ▼               ▼
Code Quality      Build &         Security
(SonarQube)    Push to ECR         Scan
(Trivy)
│
┌───────────────┼───────────────┐
▼               ▼               ▼
Deploy           Deploy          Deploy
to Dev         to Staging     to Production
(auto)           (auto)        (with approval)
│               │               │
▼               ▼               ▼
EKS (dev ns)   EKS (staging ns)  EKS (prod ns)
---

## 🔄 Pipeline Stages

| Stage | Tool | Description |
|---|---|---|
| **1. Checkout** | Git | Pull latest source code |
| **2. Code Quality** | SonarQube | Static analysis and quality gate |
| **3. Build Image** | Docker | Multi-stage build for minimal image size |
| **4. Security Scan** | Trivy | Scan image for critical vulnerabilities |
| **5. Push to ECR** | AWS ECR | Push tagged image to container registry |
| **6. Deploy Dev** | kubectl | Auto-deploy to dev namespace on EKS |
| **7. Health Check** | kubectl | Verify all pods are Running and healthy |
| **8. Deploy Staging** | kubectl | Auto-deploy to staging namespace |
| **9. Deploy Production** | kubectl | Deploy with manual approval gate |
| **10. Notify** | Slack | Send success/failure notification |

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **CI/CD** | Jenkins, GitHub Actions |
| **Containerisation** | Docker (multi-stage builds) |
| **Orchestration** | Kubernetes on AWS EKS |
| **Container Registry** | AWS ECR |
| **Infrastructure** | AWS (EKS, ECR, IAM, VPC) |
| **Code Quality** | SonarQube |
| **Security Scanning** | Trivy |
| **Notifications** | Slack Webhooks |
| **Scripting** | Bash |

---

## 📁 Project Structure
Devops-ci-cd-demo/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions pipeline
├── Jenkinsfile                # Jenkins pipeline
├── Dockerfile                 # Multi-stage Docker build
└── README.md
---

## ⚙️ How It Works

### Trigger
Every `git push` to `main` or `develop` automatically triggers the pipeline.
Pull requests to `main` trigger code quality checks only.
Git tags (`v*`) trigger a full production release pipeline.

### Docker Build
Uses a **multi-stage build** to keep the production image small and secure:
- Stage 1 (builder): Installs dependencies and builds the app
- Stage 2 (production): Copies only built artifacts into a minimal Alpine image
- Runs as a **non-root user** for security
- Includes a **health check** endpoint for Kubernetes liveness probes

### Deployment Strategy
- **Dev** — Auto-deploys on every push to main
- **Staging** — Auto-deploys after Dev health checks pass
- **Production** — Requires manual approval before deploying

### Rollback
```bash
# Instant rollback to previous version
kubectl rollout undo deployment/devops-demo-app -n production

# Rollback to specific revision
kubectl rollout undo deployment/devops-demo-app -n production --to-revision=3
🔧 Environment Setup
Required GitHub Secrets
Secret
Description
AWS_ACCESS_KEY_ID
AWS IAM access key
AWS_SECRET_ACCESS_KEY
AWS IAM secret key
SONAR_TOKEN
SonarQube authentication token
SONAR_HOST_URL
SonarQube server URL
SLACK_WEBHOOK_URL
Slack incoming webhook URL
Required Jenkins Credentials
Credential ID
Type
Description
docker-hub-credentials
Username/Password
Docker Hub login
aws-credentials
AWS Credentials
AWS access keys
sonarqube-token
Secret Text
SonarQube token
✨ Key Features
✅ Multi-environment pipeline — Dev → Staging → Production
✅ Multi-stage Docker build — 10x smaller production images
✅ Security scanning — Trivy scans for critical vulnerabilities before deploy
✅ Quality gates — SonarQube blocks bad code from reaching production
✅ Non-root container — Follows security best practices
✅ Health checks — Kubernetes verifies pod health before marking deployment complete
✅ Manual approval gate — Production deploys require human sign-off
✅ Instant rollback — One command to revert any deployment
✅ Slack notifications — Team gets alerted on success or failure
✅ Both Jenkins and GitHub Actions — Shows versatility across CI/CD tools
👨‍💻 Author
Vishwa Sekar
DevOps Engineer | Kubernetes | AWS | CI/CD | Terraform
🔗 LinkedIn
✍️ DevOpsVault Blog
📧 vishwasekar43@gmail.com
