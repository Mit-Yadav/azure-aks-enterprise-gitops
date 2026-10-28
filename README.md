# ☸️ Enterprise Azure Kubernetes Service (AKS) & GitOps Reference Architecture

[![Azure](https://img.shields.io/badge/Microsoft_Azure-AKS-0089D6.svg?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/services/kubernetes-service/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D.svg?logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30-326CE5.svg?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Observability](https://img.shields.io/badge/Observability-Prometheus_%26_Grafana-F46800.svg?logo=grafana&logoColor=white)](https://grafana.com/)
[![FinOps](https://img.shields.io/badge/FinOps-Infracost-00D3A9.svg?logo=infracost&logoColor=white)](https://www.infracost.io/)

Production-grade, enterprise reference architecture implementing **Azure Kubernetes Service (AKS)** on a **Hub-and-Spoke Virtual Network**, automated declarative delivery with **ArgoCD GitOps**, **Helm 3**, autoscaling via **HPA & KEDA**, end-to-end **Observability (Prometheus, Grafana, OpenTelemetry, Loki)**, and **FinOps Cost Governance with Infracost**.

---

## 🏛️ Enterprise Hub-and-Spoke Architecture

```mermaid
flowchart TD
    subgraph HubVNet ["Hub Virtual Network (10.0.0.0/16)"]
        FW[Azure Firewall / NGINX Ingress]
        Bastion[Azure Bastion]
        VPN[VPN / ExpressRoute Gateway]
    end

    subgraph SpokeVNet ["Spoke Virtual Network - AKS (10.1.0.0/16)"]
        direction TB
        subgraph SubnetNodes ["AKS Subnet (10.1.0.0/20)"]
            Node1[System Node Pool]
            Node2[User Workload Pool 1]
            Node3[User Workload Pool 2]
        end
        
        subgraph K8sWorkloads ["Kubernetes Microservices"]
            Argo[ArgoCD GitOps Controller]
            Otel[OpenTelemetry Collector]
            Prom[Prometheus & Grafana]
            Apps[Multi-tier Microservices with HPA & KEDA]
        end
    end

    HubVNet <-->|Bidirectional VNet Peering| SpokeVNet
    Apps -->|Secret CSI Driver| KV[Azure Key Vault]
```

---

## ⚡ Core Technical Capabilities

- **Secure Network Isolation**: Terraform-provisioned Hub-and-Spoke topology with Azure Firewall, private endpoints, and strict Network Security Groups (NSGs).
- **GitOps Continuous Delivery**: ArgoCD App-of-Apps pattern managing multi-environment releases (`Dev`, `SIT`, `UAT`, `Production`) with zero configuration drift and automated self-healing.
- **Dynamic Autoscaling**: Horizontal Pod Autoscaler (HPA) paired with **KEDA** (Kubernetes Event-driven Autoscaling) to handle peak traffic spikes seamlessly while preventing resource wastage.
- **Full Observability & SLI/SLO Monitoring**: Preconfigured Prometheus alert rules monitoring the **4 Golden Signals** (Latency, Traffic, Errors, Saturation) and tracking error budget burn rates to reduce **MTTR**.
- **FinOps Governance**: Infracost CI/CD integration auditing pull-request cloud expenditure shifts before deployment.

---

## 📂 Repository Layout

```
azure-aks-enterprise-gitops/
├── terraform/
│   ├── hub-spoke/              # Hub-and-Spoke VNet, Peering, Subnets, and Firewalls
│   └── aks-cluster/            # Production AKS cluster, node pools, Key Vault CSI
├── gitops/
│   ├── argocd/                 # Root App-of-Apps declarative manifests
│   └── environments/           # Multi-environment definitions (Dev, SIT, Prod)
├── helm/
│   └── microservice-app/       # Production Helm chart with HPA, KEDA, and Rolling Updates
├── observability/
│   ├── prometheus/             # PrometheusRules for Golden Signals and SLO burn rate
│   └── opentelemetry/          # OpenTelemetry collector configuration
├── finops/
│   └── infracost.yml           # Multi-project Infracost cost governance config
└── .github/
    └── workflows/
        └── infra-gitops-pipeline.yml # Automated linting, tfsec, and Infracost CI
```

---

## 🚀 Deployment Guide

### 1. Provision Hub-and-Spoke Infrastructure
```bash
cd terraform/hub-spoke
terraform init
terraform plan -out=hub.tfplan
terraform apply hub.tfplan
```

### 2. Deploy Azure Kubernetes Service
```bash
cd ../aks-cluster
terraform init
terraform plan -out=aks.tfplan
terraform apply aks.tfplan
```

### 3. Initialize ArgoCD GitOps Controller
```bash
# Connect to AKS cluster
az aks get-credentials --resource-group rg-enterprise-spoke-aks-prod --name aks-enterprise-prod

# Apply ArgoCD Root Application
kubectl apply -f gitops/argocd/root-app-of-apps.yaml
```

---

## 📊 SRE & Reliability Architecture
- **Zero-Downtime Releases**: Configured with `maxSurge: 25%` and `maxUnavailable: 0` ensuring zero packet loss during application rollouts.
- **Incident Response & MTTR**: Automated alerting notifies on-call teams when error budgets exceed 14.4x normal consumption, triggering automated remediation.

---
**Maintained by [Mithilesh Yadav](https://github.com/Mit-Yadav)** | Enterprise DevOps & SRE Engineer | Cloud & Agentic AI Architect
