"""mlbox cost command: estimates ongoing cloud spend and cost breakdown."""

from pathlib import Path
import typer
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

console = Console()


def estimate_costs():
    """Estimates monthly and hourly GCP spend for current architecture."""
    table = Table(title="MLOps-in-a-Box — Estimated GCP Monthly Costs", border_style="yellow")
    table.add_column("Resource", style="bold white")
    table.add_column("Specs / Usage", style="cyan")
    table.add_column("Estimated Monthly ($)", justify="right", style="green")

    table.add_row(
        "Vertex AI Endpoint",
        "1x n1-standard-2 (2 vCPU, 7.5GB RAM)",
        "$50 - $70",
    )
    table.add_row(
        "Cloud Storage (GCS)",
        "< 5 GB (Data, Models, Staging lifecycle)",
        "< $0.15",
    )
    table.add_row(
        "Artifact Registry",
        "< 5 GB Docker images (with 30d cleanup)",
        "< $0.50",
    )
    table.add_row(
        "Cloud Monitoring & Alerts",
        "Dashboards, metrics, and email channels",
        "Free tier ($0.00)",
    )
    table.add_row(
        "Cloud Functions (Drift + Auto-shutdown)",
        "< 1,000 invocations / month",
        "Free tier ($0.00)",
    )
    table.add_row(
        "VPC Network & Cloud NAT",
        "Minimal egress within region",
        "~$1.50 - $3.00",
    )
    table.add_section()
    table.add_row(
        "[bold]Estimated Total[/bold]",
        "[dim]With active 24/7 endpoint[/dim]",
        "[bold yellow]$52 - $75 / month[/bold yellow]",
    )

    console.print(table)

    console.print(
        Panel(
            "[bold green]Cost-Saving Tips:[/bold green]\n"
            "• [b]Auto-shutdown is enabled by default:[/b] Idle endpoints automatically scale/undeploy after 2 hours.\n"
            "• [b]Teardown when done:[/b] Run [bold cyan]mlbox destroy[/bold cyan] anytime to completely halt spend.\n"
            "• [b]Budget guardrail:[/b] Set [italic]enable_budget = true[/italic] in terraform.tfvars to receive alerts at 50%, 80%, and 100% of your threshold.",
            border_style="green",
        )
    )
