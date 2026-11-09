"""Unit tests for Iris prediction FastAPI service."""

from pathlib import Path
import sys
import pytest
from fastapi.testclient import TestClient

# Add predict directory to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent / "predict"))
from predict import app, load_model_from_storage


@pytest.fixture(scope="module")
def client():
    # Trigger model loading
    load_model_from_storage()
    with TestClient(app) as test_client:
        yield test_client


def test_health_check(client):
    """Test health check route returns healthy status."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["model_loaded"] is True


def test_predict_single_instance(client):
    """Test prediction on single Iris-setosa instance."""
    payload = {
        "instances": [
            [5.1, 3.5, 1.4, 0.2]
        ]
    }
    response = client.post("/predict", json=payload)
    assert response.status_code == 200

    data = response.json()
    assert "predictions" in data
    assert len(data["predictions"]) == 1

    pred = data["predictions"][0]
    assert pred["prediction_class"] == "setosa"
    assert pred["class_id"] == 0
    assert "probabilities" in pred
    assert sum(pred["probabilities"].values()) == pytest.approx(1.0, abs=1e-2)


def test_predict_batch_instances(client):
    """Test batch prediction across multiple samples."""
    payload = {
        "instances": [
            [5.1, 3.5, 1.4, 0.2],  # setosa
            [5.9, 3.0, 4.2, 1.5],  # versicolor
            [6.5, 3.0, 5.2, 2.0],  # virginica
        ]
    }
    response = client.post("/predict", json=payload)
    assert response.status_code == 200

    data = response.json()
    assert len(data["predictions"]) == 3
    for p in data["predictions"]:
        assert p["prediction_class"] in ["setosa", "versicolor", "virginica"]
        assert 0 <= p["class_id"] <= 2


def test_predict_invalid_feature_dimension(client):
    """Test error handling when feature dimensions are invalid (< 4 or > 4)."""
    payload = {
        "instances": [
            [5.1, 3.5]  # only 2 features instead of 4
        ]
    }
    response = client.post("/predict", json=payload)
    assert response.status_code == 400
    assert "expected 4" in response.json()["detail"]


def test_predict_empty_instances(client):
    """Test response with empty instances array."""
    payload = {"instances": []}
    response = client.post("/predict", json=payload)
    assert response.status_code == 200
    assert response.json()["predictions"] == []
