"""
Iris Classifier Training Script for GCP Vertex AI.

Trains a Random Forest model on the Iris dataset, evaluates accuracy,
and saves the trained model artifact to a local directory or Google Cloud Storage.
"""

import argparse
import json
import os
import sys
from pathlib import Path

import joblib
import numpy as np
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split


def parse_args(args=None):
    parser = argparse.ArgumentParser(description="Train Iris Classifier Model")
    parser.add_argument(
        "--output-dir",
        type=str,
        default=os.environ.get("AIP_MODEL_DIR", "./model_output"),
        help="Destination directory or gs:// bucket path for model artifacts",
    )
    parser.add_argument(
        "--n-estimators",
        type=int,
        default=100,
        help="Number of trees in random forest",
    )
    parser.add_argument(
        "--max-depth",
        type=int,
        default=4,
        help="Maximum depth of trees",
    )
    parser.add_argument(
        "--random-state",
        type=int,
        default=42,
        help="Random seed for reproducibility",
    )
    return parser.parse_args(args)


def train_model(n_estimators: int = 100, max_depth: int = 4, random_state: int = 42):
    """Loads Iris dataset, splits 80/20, trains RandomForest, and returns model and metrics."""
    iris = load_iris()
    X = iris.data
    y = iris.target
    target_names = list(iris.target_names)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=random_state, stratify=y
    )

    clf = RandomForestClassifier(
        n_estimators=n_estimators,
        max_depth=max_depth,
        random_state=random_state,
    )
    clf.fit(X_train, y_train)

    y_pred = clf.predict(X_test)
    accuracy = float(accuracy_score(y_test, y_pred))
    report = classification_report(y_test, y_pred, target_names=target_names, output_dict=True)

    metadata = {
        "accuracy": accuracy,
        "n_estimators": n_estimators,
        "max_depth": max_depth,
        "target_names": target_names,
        "feature_names": list(iris.feature_names),
        "classification_report": report,
    }

    return clf, metadata


def save_artifact(model, metadata: dict, output_dir: str):
    """Saves model.joblib and metadata.json locally or uploads to GCS."""
    if output_dir.startswith("gs://"):
        from google.cloud import storage

        # GCS upload
        temp_dir = Path("/tmp/model_artifacts")
        temp_dir.mkdir(parents=True, exist_ok=True)
        local_model_path = temp_dir / "model.joblib"
        local_meta_path = temp_dir / "metadata.json"

        joblib.dump(model, local_model_path)
        with open(local_meta_path, "w") as f:
            json.dump(metadata, f, indent=2)

        # Parse bucket and blob path
        parts = output_dir.replace("gs://", "").split("/", 1)
        bucket_name = parts[0]
        prefix = parts[1] if len(parts) > 1 else ""

        client = storage.Client()
        bucket = client.bucket(bucket_name)

        blob_model = bucket.blob(f"{prefix.rstrip('/')}/model.joblib" if prefix else "model.joblib")
        blob_model.upload_from_filename(str(local_model_path))

        blob_meta = bucket.blob(f"{prefix.rstrip('/')}/metadata.json" if prefix else "metadata.json")
        blob_meta.upload_from_filename(str(local_meta_path))

        print(f"Artifacts successfully uploaded to {output_dir}")
    else:
        out_path = Path(output_dir)
        out_path.mkdir(parents=True, exist_ok=True)

        joblib.dump(model, out_path / "model.joblib")
        with open(out_path / "metadata.json", "w") as f:
            json.dump(metadata, f, indent=2)

        print(f"Artifacts saved locally to {out_path.resolve()}")


def main():
    args = parse_args()
    print(f"Training Iris RandomForestClassifier (estimators={args.n_estimators}, max_depth={args.max_depth})...")
    model, metadata = train_model(
        n_estimators=args.n_estimators,
        max_depth=args.max_depth,
        random_state=args.random_state,
    )
    print(f"Test Accuracy: {metadata['accuracy'] * 100:.2f}%")

    if metadata["accuracy"] < 0.90:
        print("Model accuracy is below acceptable threshold (<90%)", file=sys.stderr)
        sys.exit(1)

    save_artifact(model, metadata, args.output_dir)
    print("Training job complete!")


if __name__ == "__main__":
    main()
