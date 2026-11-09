"""mlbox status command: display deployed infrastructure and model endpoints."""

from pathlib import Path
import typer
from rich.console import Console
from rich.table import Table

from mlbox.config import load_config
from mlbox.terraform import TerraformRunner

console = Console()


def show_status():
    """Displays current status of deployed MLOps infrastructure and endpoints."""
    cwd = Path.cwd()
    config = load_config(cwd)

    runner = TerraformRunner(cwd)
    outputs = runner.get_outputs() if runner.ensure_installed() else {}

    table = Table(title="MLOps-in-a-Box — Deployment Status", border_style="cyan")
    table.add_column("Resource", style="bold white")
    table.add_column("Value / Status", style="green")

    project = config.project_id if config else outputs.get("project_id", "Not configured")
    region = config.region if config else outputs.get("region", "us-central1")

    table.add_row("GCP Project", project)
    table.add_row("Region", region)
    table.add_row("Remote State Bucket", outputs.get("state_bucket_name", "Local / Not deployed"))
    table.add_row("Artifact Registry", outputs.get("registry_url", "Not deployed"))
    table.add_row("Models Storage Bucket", outputs.get("models_bucket_name", "Not deployed"))
    table.add_row("Vertex AI Endpoint ID", outputs.get("vertex_endpoint_id", "Not deployed"))
    table.add_row("CI/CD Service Account", outputs.get("cicd_service_account", "Not configured"))

    console.print(table)
