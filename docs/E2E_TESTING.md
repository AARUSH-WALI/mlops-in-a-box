# End-to-End Testing & Verification Guide

This guide describes how to verify MLOps-in-a-Box end-to-end: both locally (free, no GCP account needed) and in the cloud on GCP Vertex AI.

---

## 1. Local Testing (Zero Cost)

You can run the full prediction container and model pipeline on your local machine without creating cloud resources.

### Step 1: Run Training Locally
```bash
cd examples/iris-classifier/train
pip install -r requirements.txt
python train.py --output-dir ./local_model
```
Outputs:
- `./local_model/model.joblib`
- `./local_model/metadata.json`

### Step 2: Test the Serving API
```bash
cd ../predict
pip install -r requirements.txt
MODEL_PATH="../train/local_model/model.joblib" uvicorn predict:app --port 8080
```

### Step 3: Send Sample Prediction via cURL
In a second terminal:
```bash
curl -X POST http://localhost:8080/predict \
  -H "Content-Type: application/json" \
  -d '{
    "instances": [
      [5.1, 3.5, 1.4, 0.2],
      [6.7, 3.1, 4.4, 1.4]
    ]
  }'
```
Expected JSON Response:
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
    },
    {
      "prediction_class": "versicolor",
      "class_id": 1,
      "probabilities": {
        "setosa": 0.01,
        "versicolor": 0.92,
        "virginica": 0.07
      }
    }
  ]
}
```

---

## 2. Cloud Testing on GCP Vertex AI

### Step 1: Authenticate with GCP
```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### Step 2: Apply Infrastructure
```bash
cd examples/iris-classifier
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your GCP project_id and region

terraform init
terraform plan
terraform apply
```

### Step 3: Trigger the Deploy Workflow in GitHub Actions
1. Navigate to **Actions** -> **Deploy Model to Vertex AI**.
2. Click **Run workflow** and provide your `project_id`.
3. The workflow will:
   - Run unit tests
   - Build & push container to Artifact Registry
   - Register model in Vertex AI Model Registry
   - Deploy model to the Vertex AI Endpoint
   - Execute an automatic prediction smoke test

### Step 4: Verify Vertex AI Endpoint via gcloud CLI
```bash
ENDPOINT_ID=$(gcloud ai endpoints list --region=us-central1 --filter="displayName=iris-mlbox-endpoint" --format="value(name)" | head -n 1)

gcloud ai endpoints predict $ENDPOINT_ID \
  --region=us-central1 \
  --json-request='{"instances": [[5.1, 3.5, 1.4, 0.2]]}'
```

### Step 5: Clean Teardown
To avoid unwanted cloud charges, destroy all provisioned infrastructure when testing concludes:
```bash
cd examples/iris-classifier
terraform destroy
```
Everything created by Terraform will be removed cleanly.
