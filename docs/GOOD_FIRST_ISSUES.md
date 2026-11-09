# Seeded "Good First Issues" for Contributors

This catalog contains **12 beginner-friendly starter issues** with precise implementation steps, files to touch, and acceptance criteria. New contributors can pick any of these to start contributing to MLOps-in-a-Box!

---

### Issue 1: Add Slack Webhook Alert Integration to Budget Module
- **Labels:** `good first issue`, `terraform`, `enhancement`
- **Why:** Teams frequently use Slack channels for cloud billing alarms rather than email alone.
- **Files to touch:**
  - `modules/budget/variables.tf` (add `slack_webhook_url` optional variable)
  - `modules/budget/main.tf` (add `google_monitoring_notification_channel` of type `webhook_tokenauth` or `slack`)
  - `modules/budget/README.md`
- **Step-by-step:**
  1. Add optional variable `slack_webhook_url` in `modules/budget/variables.tf`.
  2. In `modules/budget/main.tf`, create a `google_monitoring_notification_channel` resource conditionally when `var.slack_webhook_url != ""` is passed.
  3. Attach the created channel to `google_billing_budget.monthly.monitoring_notification_channels`.
  4. Document the new input variable in `modules/budget/README.md`.
- **Acceptance Criteria:**
  - [ ] Terraform plan succeeds with and without `slack_webhook_url`.
  - [ ] `terraform test` passes.
  - [ ] Module documentation updated.

---

### Issue 2: Add PyTorch CIFAR-10 Classification Example
- **Labels:** `good first issue`, `python`, `examples`
- **Why:** Expands model framework options beyond scikit-learn for deep learning practitioners.
- **Files to touch:**
  - `examples/pytorch-cifar/train/train.py`
  - `examples/pytorch-cifar/train/Dockerfile`
  - `examples/pytorch-cifar/predict/predict.py`
  - `examples/pytorch-cifar/tests/test_predict.py`
- **Step-by-step:**
  1. Create a lightweight PyTorch CNN training script that trains a small model on CIFAR-10 or uses a pretrained MobileNetV2.
  2. Export weights to `model.pt`.
  3. Create FastAPI serving container loading `model.pt` with image decoding and softmax prediction.
  4. Add unit test with synthetic 32x32 image tensor.
- **Acceptance Criteria:**
  - [ ] PyTorch training script saves `.pt` artifact.
  - [ ] Serving container responds to `/health` and `/predict`.
  - [ ] Unit tests pass in CI.

---

### Issue 3: Implement `--format=json` and `--format=yaml` for `mlbox status`
- **Labels:** `good first issue`, `cli`, `enhancement`
- **Why:** Allows developers to pipe CLI status into scripts and CI automation tools (e.g., `jq`).
- **Files to touch:**
  - `cli/mlbox/commands/status.py`
  - `cli/tests/test_commands.py`
- **Step-by-step:**
  1. Add an optional `--format` (`-f`) option to `status.py` with choices `table` (default), `json`, and `yaml`.
  2. If `json`, serialize the outputs dictionary via `json.dumps(outputs, indent=2)`.
  3. If `yaml`, dump formatted key-values.
  4. Add unit tests in `cli/tests/test_commands.py` verifying JSON stdout parsing.
- **Acceptance Criteria:**
  - [ ] `mlbox status --format json` outputs valid JSON.
  - [ ] Unit tests verify JSON format output.

---

### Issue 4: Add Discord Webhook Notification Support in `modules/monitoring`
- **Labels:** `good first issue`, `terraform`, `monitoring`
- **Why:** Independent developers and student hackathon teams often prefer Discord servers over enterprise email alerts.
- **Files to touch:**
  - `modules/monitoring/variables.tf`
  - `modules/monitoring/main.tf`
  - `modules/monitoring/README.md`
- **Step-by-step:**
  1. Define variable `discord_webhook_url` (optional string) in `variables.tf`.
  2. Provision a webhook notification channel in `main.tf` if supplied.
  3. Bind this channel to `google_monitoring_alert_policy.high_latency` and `error_rate`.
- **Acceptance Criteria:**
  - [ ] Alerts can dispatch to Discord webhooks when provided.
  - [ ] README documentation updated with Discord setup example.

---

### Issue 5: Add TensorFlow / Keras Model Serving Template
- **Labels:** `good first issue`, `python`, `examples`
- **Why:** Support teams operating TensorFlow / Keras deep learning pipelines.
- **Files to touch:**
  - `examples/tensorflow-mnist/train/train.py`
  - `examples/tensorflow-mnist/predict/predict.py`
  - `examples/tensorflow-mnist/tests/test_predict.py`
- **Step-by-step:**
  1. Build a basic MNIST or Fashion-MNIST training script using tf.keras.
  2. Save model in SavedModel or Keras `.keras` format.
  3. Create prediction wrapper exposing standard Vertex AI `/predict` payload.
  4. Write unit tests for prediction endpoint.
- **Acceptance Criteria:**
  - [ ] Training script completes and exports model.
  - [ ] Prediction container passes unit tests.

---

### Issue 6: Add Kolmogorov-Smirnov Statistical Drift Test to Drift Cloud Function
- **Labels:** `good first issue`, `python`, `monitoring`
- **Why:** Kolmogorov-Smirnov (KS) test is a non-parametric test that evaluates complete distribution shape differences rather than just mean/std dev.
- **Files to touch:**
  - `modules/monitoring/functions/drift_check/main.py`
  - `modules/monitoring/functions/drift_check/requirements.txt`
- **Step-by-step:**
  1. Add `scipy>=1.12.0` in `requirements.txt`.
  2. In `main.py`, implement `ks_2samp` calculation between observed sample batch and baseline dataset.
  3. Set warning flag if p-value < 0.05.
  4. Return p-values and KS statistics in the returned JSON report.
- **Acceptance Criteria:**
  - [ ] Function returns KS test p-values for each feature.
  - [ ] Emits drift alert when distributions significantly diverge.

---

### Issue 7: Add `.pre-commit-config.yaml` with Terraform & Python Hooks
- **Labels:** `good first issue`, `tooling`, `developer-experience`
- **Why:** Catches lint and formatting errors locally before pushing to remote GitHub PRs.
- **Files to touch:**
  - `.pre-commit-config.yaml`
  - `CONTRIBUTING.md`
- **Step-by-step:**
  1. Create `.pre-commit-config.yaml` in repo root.
  2. Add hooks for:
     - `antonbabenko/pre-commit-terraform` (`terraform_fmt`, `terraform_validate`, `terraform_tflint`)
     - `astral-sh/ruff-pre-commit` (lint and format)
     - `pre-commit/pre-commit-hooks` (`trailing-whitespace`, `end-of-file-fixer`, `check-yaml`)
  3. Document `pre-commit install` in `CONTRIBUTING.md`.
- **Acceptance Criteria:**
  - [ ] Running `pre-commit run --all-files` passes on clean repo.
  - [ ] Instructions included in `CONTRIBUTING.md`.

---

### Issue 8: Add Cloud Run Serving Toggle for $0/Month Scale-to-Zero Mode
- **Labels:** `good first issue`, `terraform`, `cost-saving`
- **Why:** Vertex AI endpoints cost ~$50+/month minimum. Cloud Run scales to zero when idle, enabling free hosting for demos.
- **Files to touch:**
  - `modules/vertex-endpoint/variables.tf` (add `enable_cloud_run_fallback`)
  - `modules/vertex-endpoint/main.tf`
  - `modules/vertex-endpoint/outputs.tf`
  - `docs/COST_ESTIMATE.md`
- **Step-by-step:**
  1. Add `serving_target` variable (`"vertex"` or `"cloud_run"`).
  2. Conditionally deploy `google_cloud_run_v2_service` when `serving_target == "cloud_run"`.
  3. Output the Cloud Run service URL.
- **Acceptance Criteria:**
  - [ ] When selected, deploys container to Cloud Run with scale-to-zero enabled.
  - [ ] Documents cost savings in `docs/COST_ESTIMATE.md`.

---

### Issue 9: Improve Error Messages & Add Confirmation Prompts in `mlbox rollback`
- **Labels:** `good first issue`, `cli`, `ux`
- **Why:** Rollback is an emergency operation; users should see current live models and be prompted for confirmation before shifting traffic.
- **Files to touch:**
  - `cli/mlbox/commands/rollback.py`
  - `cli/tests/test_commands.py`
- **Step-by-step:**
  1. In `rollback.py`, list deployed models currently attached to the endpoint before prompting.
  2. Add `--auto-approve` flag to bypass interactive prompt.
  3. Display formatted Rich error message if gcloud command is not configured or lacks permissions.
- **Acceptance Criteria:**
  - [ ] Interactive confirmation prompt before shifting traffic.
  - [ ] Clear error message if endpoint or model is not found.

---

### Issue 10: Add SARIF Security Scanning Output to GitHub Actions CI Workflow
- **Labels:** `good first issue`, `ci`, `security`
- **Why:** Publishing SARIF reports directly into GitHub Code Scanning displays security alerts in the repo Security tab.
- **Files to touch:**
  - `.github/workflows/ci.yml`
- **Step-by-step:**
  1. Update Checkov execution step in `.github/workflows/ci.yml` to produce `--output sarif --output-file-path results.sarif`.
  2. Add step `github/codeql-action/upload-sarif@v3` targeting `results.sarif`.
- **Acceptance Criteria:**
  - [ ] CI step uploads SARIF file on pull requests.
  - [ ] Security scan findings appear in GitHub Security tab.

---

### Issue 11: Add Endpoint Warmup Ping Script to Prevent Cold-Start Latency Spikes
- **Labels:** `good first issue`, `python`, `devops`
- **Why:** Freshly deployed models often experience a high latency spike on the first prediction due to container initialization.
- **Files to touch:**
  - `cli/mlbox/commands/deploy.py`
  - `scripts/warmup_endpoint.py`
- **Step-by-step:**
  1. Create a small Python script `scripts/warmup_endpoint.py` that sends 3 consecutive dummy prediction requests after deployment.
  2. Log response times to verify latency stabilization below 200ms.
  3. Add `--warmup/--no-warmup` flag to `mlbox deploy`.
- **Acceptance Criteria:**
  - [ ] Script successfully probes health and sends warmup payload.
  - [ ] Verifies p99 latency decreases after warmup.

---

### Issue 12: Add Cost-Estimation Calculator Based on Real-Time GCP Cloud Billing Catalog
- **Labels:** `good first issue`, `cli`, `enhancement`
- **Why:** Provides dynamically accurate pricing estimates across different GCP regions (e.g., europe-west1 vs us-central1).
- **Files to touch:**
  - `cli/mlbox/commands/cost.py`
  - `cli/tests/test_commands.py`
- **Step-by-step:**
  1. Update `cli/mlbox/commands/cost.py` to accept `--region` flag.
  2. Add regional multiplier table or fetch live pricing from GCP Cloud Billing Catalog API if available.
  3. Output regional price estimates.
- **Acceptance Criteria:**
  - [ ] `mlbox cost --region us-central1` and `mlbox cost --region europe-west1` adjust pricing appropriately.
  - [ ] Unit tests verify regional pricing logic.

