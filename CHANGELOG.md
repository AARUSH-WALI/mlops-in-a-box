# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-11-09

### Added
- **Modular Terraform Foundation**:
  - `modules/bootstrap`: Google Cloud API enablement and remote state GCS bucket.
  - `modules/network`: VPC network with Private Google Access, custom subnets, firewall rules, and Cloud NAT.
  - `modules/iam`: Least-privilege service accounts and keyless Workload Identity Federation (WIF) for GitHub Actions.
  - `modules/registry`: Google Artifact Registry Docker repository with automated untagged image cleanup policies.
  - `modules/storage`: Multi-tier Cloud Storage buckets for training data, model artifacts (with 90-day Nearline archival), and staging (7-day auto-deletion).
  - `modules/vertex-endpoint`: Google Cloud Vertex AI Online Prediction Endpoint and Model Registry registration.
  - `modules/monitoring`: Cloud Monitoring observability dashboard, p99 latency & error rate alert policies, automated drift detection Cloud Function, and idle resource auto-shutdown scheduler.
  - `modules/budget`: Automated GCP monthly billing budget with alert notifications at 50%, 80%, and 100% threshold levels.
- **Reference Example Model**:
  - `examples/iris-classifier`: End-to-end scikit-learn Random Forest model.
  - Custom training script with accuracy checks and GCS artifact upload.
  - FastAPI serving container compliant with Vertex AI custom prediction container protocol (`/health`, `/predict`).
  - Unit test suite for model training accuracy (>90%) and API response validation.
- **Developer CLI (`mlbox`)**:
  - Built with Typer and Rich for clean terminal formatting.
  - Commands: `init`, `deploy`, `destroy`, `status`, `cost`, `rollback`.
- **CI/CD Automation (GitHub Actions)**:
  - `ci.yml`: Terraform format check, validation, tflint, Checkov IaC security scan, Python CLI tests, and model tests.
  - `train.yml`: Keyless training container build and custom training job submission.
  - `deploy.yml`: Serving container build, Vertex AI model registration, endpoint deployment, and live smoke test.
  - `rollback.yml`: One-click traffic rollback to previous model versions.
- **Documentation & Community**:
  - Architecture overview with Mermaid diagrams (`docs/ARCHITECTURE.md`).
  - Cost breakdown and financial transparency guide (`docs/COST_ESTIMATE.md`).
  - Step-by-step quickstart guide (`docs/QUICKSTART.md`).
  - End-to-end verification guide for local & cloud testing (`docs/E2E_TESTING.md`).
  - Project Roadmap (`docs/ROADMAP.md`).
  - 12 structured good first issue tickets with implementation steps (`docs/GOOD_FIRST_ISSUES.md`).
  - Issue templates (Bug, Feature Request, Good First Issue Proposal) and PR template.
  - Code of Conduct, Contributing guide, Security policy, MIT License.
