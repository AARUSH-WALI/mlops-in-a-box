"""
Cloud Function: Prediction Drift Detection for Vertex AI Models.

Periodically queries recent prediction logs, compares feature distributions
against baseline training statistics, and emits Cloud Monitoring alerts if
statistical drift is detected.
"""

import json
import logging
import os
import functions_framework
import numpy as np

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("drift-detector")

# Baseline training summary statistics for Iris dataset (for illustration & default)
DEFAULT_BASELINE = {
    "sepal_length": {"mean": 5.843, "std": 0.828},
    "sepal_width": {"mean": 3.057, "std": 0.436},
    "petal_length": {"mean": 3.758, "std": 1.765},
    "petal_width": {"mean": 1.199, "std": 0.762},
}


def calculate_z_score_drift(observed_mean: float, baseline_mean: float, baseline_std: float) -> float:
    """Calculates standardized difference between observed and baseline distribution."""
    if baseline_std == 0:
        return 0.0
    return abs(observed_mean - baseline_mean) / baseline_std


@functions_framework.http
def check_drift(request):
    """
    HTTP entrypoint triggered by Cloud Scheduler.
    Inspects recent inferences and checks for feature drift.
    """
    project_id = os.environ.get("GCP_PROJECT", "")
    drift_threshold = float(os.environ.get("DRIFT_Z_THRESHOLD", "2.5"))

    logger.info(f"Executing drift detection check (threshold z={drift_threshold})...")

    # In production, query Cloud Logging for Vertex AI predict request logs:
    # log_filter = f'resource.type="aiplatform.googleapis.com/Endpoint" AND jsonPayload.instances:*'
    # For demonstration/testing, simulate observed inference batch:
    simulated_batch = [
        [5.9, 3.1, 3.8, 1.2],
        [6.1, 3.0, 4.0, 1.3],
        [5.7, 3.2, 3.6, 1.1],
        [6.0, 2.9, 3.9, 1.2],
    ]

    arr = np.array(simulated_batch)
    features = ["sepal_length", "sepal_width", "petal_length", "petal_width"]

    drift_report = {}
    any_drift = False

    for idx, feat in enumerate(features):
        obs_mean = float(np.mean(arr[:, idx]))
        obs_std = float(np.std(arr[:, idx]))
        base_stats = DEFAULT_BASELINE.get(feat, {"mean": obs_mean, "std": 1.0})

        z_score = calculate_z_score_drift(obs_mean, base_stats["mean"], base_stats["std"])
        drift_detected = z_score > drift_threshold

        drift_report[feat] = {
            "observed_mean": round(obs_mean, 3),
            "baseline_mean": round(base_stats["mean"], 3),
            "z_score": round(z_score, 3),
            "drift_detected": drift_detected,
        }

        if drift_detected:
            any_drift = True
            logger.warning(
                f"DRIFT ALERT: Feature '{feat}' showed significant drift (z={z_score:.2f} > {drift_threshold})"
            )

    result = {
        "status": "drift_detected" if any_drift else "normal",
        "drift_detected": any_drift,
        "features": drift_report,
    }

    logger.info(f"Drift check completed: {result['status']}")
    return json.dumps(result), 200, {"Content-Type": "application/json"}
