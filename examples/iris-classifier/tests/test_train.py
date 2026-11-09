"""Unit tests for Iris model training script."""

import json
import tempfile
from pathlib import Path
import pytest
import joblib
from sklearn.base import is_classifier

import sys
# Add train directory to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent / "train"))
from train import train_model, save_artifact, parse_args


def test_train_model_accuracy_and_types():
    """Verify trained model achieves > 90% accuracy and outputs proper metrics structure."""
    model, metadata = train_model(n_estimators=50, max_depth=3, random_state=42)

    assert is_classifier(model), "Trained model should be a valid scikit-learn classifier"
    assert metadata["accuracy"] >= 0.90, f"Expected accuracy >= 0.90, got {metadata['accuracy']}"
    assert "classification_report" in metadata
    assert len(metadata["target_names"]) == 3
    assert metadata["target_names"] == ["setosa", "versicolor", "virginica"]
    assert len(metadata["feature_names"]) == 4


def test_save_artifact_locally():
    """Ensure artifacts are saved locally to specified directory with correct structure."""
    model, metadata = train_model(n_estimators=10, max_depth=2, random_state=42)

    with tempfile.TemporaryDirectory() as tmpdir:
        save_artifact(model, metadata, tmpdir)

        model_file = Path(tmpdir) / "model.joblib"
        meta_file = Path(tmpdir) / "metadata.json"

        assert model_file.exists(), "model.joblib must be created"
        assert meta_file.exists(), "metadata.json must be created"

        # Check loaded model can make predictions
        loaded_model = joblib.load(model_file)
        preds = loaded_model.predict([[5.1, 3.5, 1.4, 0.2]])
        assert len(preds) == 1
        assert preds[0] in [0, 1, 2]

        # Check metadata json
        with open(meta_file) as f:
            saved_meta = json.load(f)
        assert saved_meta["accuracy"] == metadata["accuracy"]


def test_parse_args_defaults():
    """Verify CLI argument defaults."""
    args = parse_args([])
    assert args.n_estimators == 100
    assert args.max_depth == 4
    assert args.random_state == 42
