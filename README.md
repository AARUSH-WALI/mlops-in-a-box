<div align="center">

# 📦 MLOps-in-a-Box

**One command to deploy a monitored ML model on GCP Vertex AI, with CI/CD and cost guardrails.**

[![CI](https://github.com/aarushwali/mlops-in-a-box/actions/workflows/ci.yml/badge.svg)](https://github.com/aarushwali/mlops-in-a-box/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.6-purple.svg)](https://www.terraform.io/)
[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![Google Cloud](https://img.shields.io/badge/GCP-Vertex%20AI-orange.svg)](https://cloud.google.com/vertex-ai)

[Quickstart](docs/QUICKSTART.md) • [Architecture](docs/ARCHITECTURE.md) • [Cost Guide](docs/COST_ESTIMATE.md) • [Roadmap](docs/ROADMAP.md) • [Contributing](CONTRIBUTING.md)

---

</div>

## 💡 Why This Exists

Students, data scientists, and startup engineers lose **days or weeks** setting up production cloud infrastructure: IAM permissions, VPC networking, container registries, model serving endpoints, monitoring, CI/CD pipelines, and cost guardrails.

**MLOps-in-a-Box** turns that multi-week struggle into a single, clean command:
```bash
mlbox init && mlbox deploy
```
From zero to a monitored, production-grade Vertex AI endpoint in under **30 minutes**.

---

## 🚀 Demo

```
$ mlbox init --project-id my-gcp-project
Saved configuration to .mlbox.json
Created terraform.tfvars
Workspace ready!

$ mlbox deploy
Deploying MLOps infrastructure for my-gcp-project...
[+] google_project_service: 12 APIs enabled
[+] google_compute_network: mlops-vpc created
[+] google_storage_bucket: data, models, staging created
[+] google_vertex_ai_endpoint: iris-endpoint created
Model Endpoint Live! Endpoint ID: 4192847291847192841
```

---

## ✨ Key Features

- 🏗️ **Modular Terraform**: 8 reusable modules (`bootstrap`, `network`, `iam`, `registry`, `storage`, `vertex-endpoint`, `monitoring`, `budget`)
- 🔑 **Zero Long-Lived Keys**: Keyless GitHub Actions authentication via **Workload Identity Federation (WIF)**
- 🛡️ **Proactive Cost Guardrails**:
  - Auto-shutdown of idle prediction endpoints (after 2 hours of 0 traffic)
  - Monthly budget alerts at 50%, 80%, and 100% spend thresholds
  - One-command total destruction (`mlbox destroy`)
- 📊 **Model Observability**: Real-time Cloud Monitoring dashboards for p50/p95/p99 latency, RPS, and 4xx/5xx errors
- 🔍 **Statistical Drift Detection**: Scheduled Cloud Function checking incoming feature distributions against training baselines
- 🔄 **Production CI/CD**: Automated GitHub Actions workflows for model training, container building, canary deployment, and instant rollback
- 💻 **Developer CLI (`mlbox`)**: Typer-powered terminal interface for one-command lifecycle management

---

## 💰 Cost Breakdown & Financial Transparency

> [!WARNING]
> Vertex AI prediction endpoints incur hourly compute fees while running. MLOps-in-a-Box includes **automatic idle shutdown** to undeploy unused models and **budget threshold alerts**.

| Resource | Spec | Estimated Monthly Spend |
| :--- | :--- | :--- |
| **Vertex AI Prediction Endpoint** | 1× `n1-standard-2` | **$50.00 – $72.00** *(if active 24/7)* |
| **Cloud Storage (GCS)** | Datasets, models, staging | **< $0.15** |
| **Artifact Registry** | Container images (with 30d cleanup) | **< $0.50** |
| **Cloud Monitoring & Alerts** | Observability dashboards & metrics | **$0.00 (Free Tier)** |
| **Cloud Functions & Scheduler** | Drift check & idle auto-shutdown | **$0.00 (Free Tier)** |
| **VPC & Cloud NAT** | Private egress | **~$1.50 – $3.00** |
| **Total (Continuous Active)** | | **~$52.00 – $75.00 / month** |

*Want zero cloud costs? See our [End-to-End Testing Guide](docs/E2E_TESTING.md) to run everything locally for free using Docker and FastAPI.*

---

## ⚡ 5-Minute Quickstart

### Prerequisites
- [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install)
- [Terraform >= 1.6](https://developer.hashicorp.com/terraform/install)
- [Python >= 3.10](https://www.python.org/)

### 1. Install `mlbox` CLI
```bash
git clone https://github.com/aarushwali/mlops-in-a-box.git
cd mlops-in-a-box
pip install -e cli/
```

### 2. Authenticate with GCP
```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 3. Deploy
```bash
cd examples/iris-classifier
mlbox init --project-id YOUR_PROJECT_ID
mlbox deploy
```

### 4. Send a Prediction Request
```bash
ENDPOINT_ID=$(gcloud ai endpoints list --region=us-central1 --filter="displayName=iris-mlbox-endpoint" --format="value(name)" | head -n 1)

gcloud ai endpoints predict $ENDPOINT_ID \
  --region=us-central1 \
  --json-request='{"instances": [[5.1, 3.5, 1.4, 0.2]]}'
```

### 5. Clean Teardown
```bash
mlbox destroy
```

---

## 🏛️ Repository Structure

```
mlops-in-a-box/
├── modules/
│   ├── bootstrap/           # GCP APIs, provider setup, state storage
│   ├── network/             # VPC, subnets, firewall rules, Cloud NAT
│   ├── iam/                 # Least-privilege SAs & Workload Identity Federation
│   ├── registry/            # Artifact Registry with untagged cleanup
│   ├── storage/             # GCS buckets (data, models, ephemeral staging)
│   ├── vertex-endpoint/     # Vertex AI endpoint & Model Registry
│   ├── monitoring/          # Dashboards, p99 alerts, drift check, auto-shutdown
│   └── budget/              # Billing budget alerts (50%, 80%, 100%)
├── examples/
│   └── iris-classifier/     # End-to-end runnable example
│       ├── main.tf          # Composed root Terraform module
│       ├── train/           # scikit-learn training script & Dockerfile
│       ├── predict/         # FastAPI serving container & Dockerfile
│       └── tests/           # Training & serving unit tests
├── cli/                     # 'mlbox' Typer-based CLI
├── .github/workflows/       # CI/CD: lint, test, train, deploy, rollback
├── tests/
│   ├── terraform/           # Terraform plan and unit tests (.tftest.hcl)
│   └── security/            # Checkov IaC security scanning policy
└── docs/                    # Architecture, quickstart, cost guide, roadmap
```

---

## 🔒 Security Posture

- **No Long-Lived Service Account Keys**: Credentials are never exported to disk or GitHub secrets.
- **Workload Identity Federation**: GitHub Actions uses short-lived tokens via OIDC.
- **VPC with Private Google Access**: Compute instances have no public IPs.
- **Automated IaC Security Scanning**: Checkov scans every module in CI on pull requests.
- **Dependabot**: Automated dependency tracking and security patches.

---

## 🤝 Contributing

We welcome all contributions! Whether you're adding support for AWS SageMaker, implementing a PyTorch example, or fixing documentation typos:
1. Check our [good first issues](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
2. Read the [Contributing Guide](CONTRIBUTING.md)
3. Submit a Pull Request!

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
