# MLOps-in-a-Box Cost Estimate & Guardrails Guide

One of the primary goals of MLOps-in-a-Box is financial transparency and safety. Cloud ML services can become costly if instances remain running unmonitored.

---

## Estimated Monthly Costs (GCP us-central1)

The table below outlines expected costs for our minimal reference architecture:

| Component | Resource Specification | Pricing Model | Estimated Monthly Cost |
| :--- | :--- | :--- | :--- |
| **Vertex AI Prediction Endpoint** | 1× `n1-standard-2` (2 vCPU, 7.5GB RAM) | ~$0.10 / hour | **$50.00 – $72.00** *(if active 24/7)* |
| **Google Cloud Storage (GCS)** | < 5 GB (Datasets, models, staging) | Standard: $0.02 / GB / mo | **< $0.15** |
| **Artifact Registry** | < 5 GB Docker images | $0.10 / GB / mo | **< $0.50** |
| **Cloud Monitoring & Logging** | Dashboards, metrics, log storage | Free tier covers first 50 MiB/mo | **$0.00 (Free Tier)** |
| **Cloud Functions (Gen 2)** | Drift check (6h) & Auto-shutdown (1h) | 2M free invocations/mo | **$0.00 (Free Tier)** |
| **Cloud Scheduler** | 2 scheduled cron jobs | 3 free jobs / month | **$0.00 (Free Tier)** |
| **VPC & Cloud NAT** | Private egress for container pulls | ~$0.0014 / hr + data | **~$1.50 – $3.00** |
| **Total Estimated Spend** | Full stack running continuously | | **~$52.00 – $75.00 / month** |

---

## Built-In Cost Guardrails

MLOps-in-a-Box includes multiple mechanisms to prevent surprise charges:

### 1. Idle Resource Auto-Shutdown
By default, the `monitoring` module schedules a check every hour. If your endpoint has processed **0 requests** over the preceding 2 hours, it automatically undeploys the model to stop compute charges.

### 2. Proactive Budget Alerts
The `budget` module allows you to define a monthly budget (default: $100). Google Cloud dispatches email alerts as soon as spend crosses:
- **50% of monthly budget**
- **80% of monthly budget**
- **100% of forecasted monthly budget**

### 3. Immediate Teardown
When you are finished testing or demoing, run:
```bash
mlbox destroy
```
or:
```bash
cd examples/iris-classifier && terraform destroy
```
This cleanly removes all provisioned resources.

---

## How to Run Completely Free (Zero Cloud Charges)

If you don't wish to incur any cloud charges:
1. Run everything locally using Docker and the local FastAPI server:
   ```bash
   cd examples/iris-classifier/predict
   uvicorn predict:app --port 8080
   ```
2. Unit tests and CI pipelines run entirely within GitHub Actions' free tier runners.
