"""
Cloud Function: Idle Resource Auto-Shutdown for Vertex AI Endpoints.

Periodically inspects traffic volume over the past N hours using Cloud Monitoring.
If no prediction requests were received, scales down or undeploys models to
prevent idle hourly computing charges.
"""

import json
import logging
import os
import time
import functions_framework
from google.cloud import aiplatform, monitoring_v3

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("auto-shutdown")


def get_endpoint_prediction_count(project_id: str, endpoint_id: str, hours: int = 2) -> int:
    """Queries Cloud Monitoring for total predict requests in the last N hours."""
    try:
        client = monitoring_v3.MetricServiceClient()
        project_name = f"projects/{project_id}"

        now = time.time()
        interval = monitoring_v3.TimeInterval(
            {
                "end_time": {"seconds": int(now)},
                "start_time": {"seconds": int(now - (hours * 3600))},
            }
        )

        # Metric for Vertex AI online prediction request count
        filter_str = (
            f'metric.type = "aiplatform.googleapis.com/prediction/online/prediction_count" '
            f'AND resource.labels.endpoint_id = "{endpoint_id}"'
        )

        results = client.list_time_series(
            request={
                "name": project_name,
                "filter": filter_str,
                "interval": interval,
                "view": monitoring_v3.ListTimeSeriesRequest.TimeSeriesView.FULL,
            }
        )

        total_requests = 0
        for series in results:
            for point in series.points:
                total_requests += point.value.int64_value

        return total_requests
    except Exception as e:
        logger.warning(f"Could not query metric series ({e}). Assuming idle check fallback.")
        return 0


@functions_framework.http
def auto_shutdown_check(request):
    """Entry point for Cloud Scheduler to evaluate idle endpoints."""
    project_id = os.environ.get("GCP_PROJECT", "")
    region = os.environ.get("GCP_REGION", "us-central1")
    endpoint_id = os.environ.get("VERTEX_ENDPOINT_ID", "")
    idle_hours = int(os.environ.get("IDLE_TIMEOUT_HOURS", "2"))

    logger.info(f"Checking idle status for endpoint {endpoint_id} in {region} over {idle_hours}h...")

    if not endpoint_id:
        return json.dumps({"status": "skipped", "reason": "No VERTEX_ENDPOINT_ID configured"}), 200

    request_count = get_endpoint_prediction_count(project_id, endpoint_id, idle_hours)
    logger.info(f"Total requests in past {idle_hours} hours: {request_count}")

    action_taken = "none"

    if request_count == 0:
        logger.info(f"Endpoint {endpoint_id} has been idle for {idle_hours}+ hours. Initiating auto-shutdown...")
        try:
            aiplatform.init(project=project_id, location=region)
            endpoint = aiplatform.Endpoint(endpoint_name=endpoint_id)

            deployed_models = endpoint.list_models()
            if deployed_models:
                for dm in deployed_models:
                    logger.info(f"Undeploying idle model {dm.id} to stop hourly charges...")
                    endpoint.undeploy(deployed_model_id=dm.id)
                action_taken = "undeployed_idle_models"
            else:
                action_taken = "already_empty"
        except Exception as e:
            logger.error(f"Failed to undeploy models on endpoint: {e}")
            action_taken = f"error: {str(e)}"
    else:
        logger.info(f"Endpoint is actively in use ({request_count} requests). No action needed.")
        action_taken = "active_no_action"

    return json.dumps({
        "endpoint_id": endpoint_id,
        "requests_last_window": request_count,
        "action": action_taken,
    }), 200, {"Content-Type": "application/json"}
