"""
FastAPI Prediction Server for Vertex AI Custom Prediction Container.

Complies with Vertex AI container requirements:
- Listens on port specified by AIP_HTTP_PORT (default 8080)
- Responds to health checks on AIP_HEALTH_ROUTE (default /health)
- Handles batch prediction on AIP_PREDICT_ROUTE (default /predict)
"""

import json
import os
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Any, Dict, List, Union

import joblib
import numpy as np
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier

TARGET_NAMES = ["setosa", "versicolor", "virginica"]
FEATURE_NAMES = [
    "sepal length (cm)",
    "sepal width (cm)",
    "petal length (cm)",
    "petal width (cm)",
]

# Global model holder
model = None


def load_model_from_storage():
    """Loads the model artifact from AIP_STORAGE_URI, local file, or builds fallback."""
    global model

    storage_uri = os.environ.get("AIP_STORAGE_URI", "")
    local_path = os.environ.get("MODEL_PATH", "./model.joblib")

    # 1. Try GCS if AIP_STORAGE_URI is provided
    if storage_uri.startswith("gs://"):
        try:
            from google.cloud import storage

            parts = storage_uri.replace("gs://", "").split("/", 1)
            bucket_name = parts[0]
            prefix = parts[1].rstrip("/") if len(parts) > 1 else ""

            client = storage.Client()
            bucket = client.bucket(bucket_name)

            dest_path = Path("/tmp/model.joblib")
            blob = bucket.blob(f"{prefix}/model.joblib" if prefix else "model.joblib")
            if blob.exists():
                blob.download_to_filename(str(dest_path))
                model = joblib.load(dest_path)
                print(f"Loaded model from GCS: {storage_uri}")
                return
        except Exception as e:
            print(f"Failed to load from GCS ({e}), falling back to local...")

    # 2. Try local file path
    if Path(local_path).exists():
        try:
            model = joblib.load(local_path)
            print(f"Loaded model from local path: {local_path}")
            return
        except Exception as e:
            print(f"Failed to load local model ({e})")

    # 3. Fallback: train on-the-fly for immediate readiness and testing
    print("No model artifact found on disk/GCS. Initializing fallback model on Iris dataset...")
    iris = load_iris()
    clf = RandomForestClassifier(n_estimators=50, max_depth=3, random_state=42)
    clf.fit(iris.data, iris.target)
    model = clf
    print("Fallback Iris model initialized.")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Load or initialize model
    load_model_from_storage()
    yield
    # Teardown logic if needed
    print("Shutting down prediction server.")


app = FastAPI(
    title="Iris Classifier Prediction Service",
    description="Vertex AI custom prediction container endpoint for Iris classification",
    version="1.0.0",
    lifespan=lifespan,
)


class PredictRequest(BaseModel):
    # Vertex AI standard: instances is a list of feature lists or dicts
    instances: List[List[float]] = Field(
        ...,
        description="List of feature lists. Each feature list has 4 elements: [sepal length, sepal width, petal length, petal width]",
        json_schema_extra={
            "example": [
                [5.1, 3.5, 1.4, 0.2],
                [6.7, 3.1, 4.4, 1.4],
                [6.3, 3.3, 6.0, 2.5],
            ]
        },
    )


class PredictionResult(BaseModel):
    prediction_class: str
    class_id: int
    probabilities: Dict[str, float]


class PredictResponse(BaseModel):
    predictions: List[PredictionResult]


@app.get(os.environ.get("AIP_HEALTH_ROUTE", "/health"))
def health_check():
    """Vertex AI health check endpoint. Must return 200 when ready to receive traffic."""
    if model is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Model not initialized",
        )
    return {"status": "healthy", "model_loaded": True}


@app.post(os.environ.get("AIP_PREDICT_ROUTE", "/predict"), response_model=PredictResponse)
def predict(request: PredictRequest):
    """
    Online prediction endpoint compliant with Vertex AI payload specifications.
    Accepts 4 features per instance:
    - sepal length (cm)
    - sepal width (cm)
    - petal length (cm)
    - petal width (cm)
    """
    if model is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Model is not loaded",
        )

    instances = request.instances
    if not instances:
        return PredictResponse(predictions=[])

    # Validate feature dimension
    for i, inst in enumerate(instances):
        if len(inst) != 4:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Instance {i} has {len(inst)} features, expected 4.",
            )

    try:
        X = np.array(instances)
        pred_ids = model.predict(X)
        pred_probs = model.predict_proba(X)

        results = []
        for pid, probs in zip(pred_ids, pred_probs):
            prob_dict = {TARGET_NAMES[idx]: float(round(p, 4)) for idx, p in enumerate(probs)}
            results.append(
                PredictionResult(
                    prediction_class=TARGET_NAMES[int(pid)],
                    class_id=int(pid),
                    probabilities=prob_dict,
                )
            )

        return PredictResponse(predictions=results)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Inference error: {str(e)}",
        )


if __name__ == "__main__":
    import uvicorn

    port = int(os.environ.get("AIP_HTTP_PORT", 8080))
    uvicorn.run("predict:app", host="0.0.0.0", port=port, log_level="info")
