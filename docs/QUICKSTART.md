# MLOps-in-a-Box Quickstart Guide

This guide will take you from a fresh Google Cloud project to a live, monitored Vertex AI prediction endpoint in under 30 minutes.

---

## Prerequisites

1. **Google Cloud Account** with billing enabled ([Create free GCP account](https://cloud.google.com/free))
2. **Tools installed locally**:
   - [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6
   - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (`gcloud`)
   - [Python](https://www.python.org/) >= 3.10
   - [Git](https://git-scm.com/)

---

## Step 1: Clone the Repository & Install CLI

```bash
git clone https://github.com/aarushwali/mlops-in-a-box.git
cd mlops-in-a-box

# Install mlbox CLI
pip install -e cli/
```

Verify installation:
```bash
mlbox --version
# Expected: mlbox version 0.1.0
```

---

## Step 2: Authenticate with Google Cloud

```bash
# Log in to Google Cloud
gcloud auth login

# Log in for Application Default Credentials (used by Terraform)
gcloud auth application-default login

# Set your active GCP project
gcloud config set project YOUR_PROJECT_ID
```

---

## Step 3: Initialize the Project

Run `mlbox init`:
```bash
cd examples/iris-classifier
mlbox init --project-id YOUR_PROJECT_ID --region us-central1
```

This creates:
- `.mlbox.json` configuration
- `terraform.tfvars` file populated with your project settings

---

## Step 4: Deploy Infrastructure & Models

Deploy everything with one command:
```bash
mlbox deploy
```

What this does:
1. Enables necessary Google Cloud APIs
2. Configures a VPC with Private Google Access
3. Creates IAM service accounts with least privilege and Workload Identity Federation
4. Sets up an Artifact Registry repository and GCS storage buckets
5. Registers the Iris Classifier model and deploys a Vertex AI Prediction Endpoint
6. Sets up monitoring dashboards, latency alert policies, and idle auto-shutdown

---

## Step 5: Test Your Live Endpoint

Send a sample prediction request to your endpoint:
```bash
ENDPOINT_ID=$(gcloud ai endpoints list --region=us-central1 --filter="displayName=iris-mlbox-endpoint" --format="value(name)" | head -n 1)

gcloud ai endpoints predict $ENDPOINT_ID \
  --region=us-central1 \
  --json-request='{"instances": [[5.1, 3.5, 1.4, 0.2]]}'
```

Expected Output:
```json
{
  "predictions": [
    {
      "prediction_class": "setosa",
      "class_id": 0,
      "probabilities": {
        "setosa": 0.98,
        "versicolor": 0.02,
        "virginica": 0.0
      }
    }
  ]
}
```

---

## Step 6: View Monitoring & Costs

Check live status:
```bash
mlbox status
mlbox cost
```

Visit the **Google Cloud Console** -> **Monitoring** -> **Dashboards** to view live inference latency, throughput, and error graphs.

---

## Step 7: Clean Teardown

When you are done testing, cleanly destroy all resources to stop billing:
```bash
mlbox destroy
```
All provisioned infrastructure will be safely removed.
