# MLOps-in-a-Box Roadmap

This roadmap outlines planned capabilities and extensions for future releases. Community contributions and feedback are welcomed!

---

## Phase 1: v0.1.0 (Current MVP)
- [x] Complete modular GCP Terraform foundation (`bootstrap`, `network`, `iam`, `registry`, `storage`, `vertex-endpoint`, `monitoring`, `budget`)
- [x] Keyless authentication via GitHub Workload Identity Federation (no SA keys)
- [x] Iris Classifier scikit-learn example (train + FastAPI serving container)
- [x] Automated GitHub Actions CI/CD (lint, unit tests, model train, deploy, rollback)
- [x] Cloud Monitoring dashboards (latency p50/p95/p99, error counts, request rate)
- [x] Automated drift detection function & idle auto-shutdown Cloud Scheduler job
- [x] `mlbox` CLI (`init`, `deploy`, `destroy`, `status`, `cost`, `rollback`)

---

## Phase 2: Multi-Framework & Cloud Run Mode (v0.2.0)
- [ ] **Cloud Run Serving Option (Scale-to-Zero):** Add a toggle in Terraform to deploy containers to Cloud Run for students and hobbyists wanting $0/month idle cost.
- [ ] **PyTorch Example:** Add an image classification model (e.g. ResNet on CIFAR-10) using PyTorch and TorchServe.
- [ ] **TensorFlow / Keras Example:** Add a tabular or NLP classification model using TensorFlow Serving.
- [ ] **Slack & Discord Alert Channels:** Module extension to post budget and drift alerts to Discord or Slack webhooks.

---

## Phase 3: Advanced MLOps Features (v0.3.0)
- [ ] **Vertex AI Feature Store Integration:** Add Terraform support for Vertex AI Feature Store.
- [ ] **A/B Testing & Multi-Armed Bandit Traffic Splitting:** Workflow support for splitting traffic across multiple deployed models (e.g., 90% Champion / 10% Challenger).
- [ ] **Full Kolmogorov-Smirnov & PSI Drift Analytics:** Statistical test runner generating HTML distribution comparison reports.
- [ ] **Model Explainability (XAI):** Enable Vertex Explainable AI (Integrated Gradients / Shapley values) on prediction endpoints.

---

## Phase 4: Multi-Cloud Expansion (v0.4.0+)
- [ ] **AWS SageMaker Module:** Complementary Terraform modules for Amazon SageMaker endpoints.
- [ ] **Azure Machine Learning Module:** Complementary Terraform modules for Azure ML managed online endpoints.

