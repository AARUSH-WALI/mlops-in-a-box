"""mlbox deploy command: apply terraform and deploy model."""

from pathlib import Path
import typer
from rich.console import Console

from mlbox.config import load_config
from mlbox.terraform import TerraformRunner

console = Console()


def deploy_project(
    auto_approve: bool = typer.Option(
        False, "--auto-approve", "-y", help="Skip confirmation prompt for terraform apply"
    ),
):
    """Provisions GCP infrastructure and deploys model to Vertex AI."""
    cwd = Path.cwd()
    config = load_config(cwd)

    if not config:
        console.print("[red]No .mlbox.json configuration found.[/red] Please run [bold]mlbox init[/bold] first.")
        raise typer.Exit(code=1)

    console.print(f"[bold cyan]Deploying MLOps infrastructure for {config.project_id}...[/bold cyan]")
    runner = TerraformRunner(cwd)
    if not runner.ensure_installed():
        raise typer.Exit(code=1)

    success = runner.apply(auto_approve=auto_approve)
    if not success:
        console.print("[bold red]Deployment failed.[/bold red]")
        raise typer.Exit(code=1)

    outputs = runner.get_outputs()
    endpoint_id = outputs.get("vertex_endpoint_id", "Provisioned")
    console.print(f"[bold green]Model Endpoint Live![/bold green] Endpoint ID: [cyan]{endpoint_id}[/cyan]")
