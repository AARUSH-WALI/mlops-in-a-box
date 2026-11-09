"""mlbox rollback command: reverts prediction traffic to a previous model."""

import typer
from rich.console import Console

from mlbox.terraform import run_command

console = Console()


def rollback_model(
    endpoint_id: str = typer.Option(..., "--endpoint-id", "-e", prompt=True, help="Vertex AI Endpoint ID"),
    target_model_id: str = typer.Option(
        ..., "--target-model-id", "-m", prompt=True, help="Deployed model ID to shift 100% traffic to"
    ),
    region: str = typer.Option("us-central1", "--region", "-r", help="GCP Region"),
):
    """Reverts traffic on a Vertex AI endpoint to a prior model deployment."""
    console.print(f"[bold yellow]Shifting 100% traffic to model {target_model_id} on endpoint {endpoint_id}...[/bold yellow]")

    cmd = [
        "gcloud",
        "ai",
        "endpoints",
        "set-traffic-split",
        endpoint_id,
        f"--region={region}",
        f"--traffic-split={target_model_id}=100",
    ]

    code, stdout, stderr = run_command(cmd)
    if code != 0:
        console.print(f"[bold red]Rollback command failed:[/bold red]\n{stderr or stdout}")
        raise typer.Exit(code=1)

    console.print("[bold green]Rollback completed successfully![/bold green] Traffic shifted to previous model.")
