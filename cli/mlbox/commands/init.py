"""mlbox init command: bootstrap a new project from templates."""

from pathlib import Path
import typer
from rich.console import Console
from rich.panel import Panel

from mlbox.config import MLBoxConfig, save_config
from mlbox.terraform import TerraformRunner

console = Console()


def init_project(
    project_id: str = typer.Option(..., "--project-id", "-p", prompt=True, help="GCP Project ID"),
    region: str = typer.Option("us-central1", "--region", "-r", help="GCP Region"),
    template: str = typer.Option("iris-classifier", "--template", "-t", help="ML Template"),
    github_org: str = typer.Option("", "--github-org", help="GitHub username/organization"),
    github_repo: str = typer.Option("mlops-in-a-box", "--github-repo", help="GitHub repository name"),
    run_tf_init: bool = typer.Option(False, "--init-terraform", help="Run terraform init after scaffold"),
):
    """Initializes a new MLOps-in-a-Box project workspace."""
    console.print(
        Panel.fit(
            "[bold cyan]MLOps-in-a-Box[/bold cyan] — Project Initializer\n"
            f"[dim]Project:[/dim] {project_id} | [dim]Region:[/dim] {region} | [dim]Template:[/dim] {template}",
            border_style="cyan",
        )
    )

    cwd = Path.cwd()
    config = MLBoxConfig(
        project_id=project_id,
        region=region,
        template=template,
        github_org=github_org,
        github_repo=github_repo,
    )
    save_config(config, cwd)
    console.print("[green]Saved configuration to [bold].mlbox.json[/bold][/green]")

    # Create local terraform.tfvars if it does not exist
    tfvars_file = cwd / "terraform.tfvars"
    if not tfvars_file.exists():
        content = (
            f'project_id  = "{project_id}"\n'
            f'region      = "{region}"\n'
            f'name_prefix = "mlbox"\n'
            f'github_org  = "{github_org}"\n'
            f'github_repo = "{github_repo}"\n'
        )
        tfvars_file.write_text(content, encoding="utf-8")
        console.print("[green]Created [bold]terraform.tfvars[/bold][/green]")

    if run_tf_init:
        runner = TerraformRunner(cwd)
        if runner.ensure_installed():
            runner.init()

    console.print("\n[bold green]Workspace ready![/bold green] Next step:")
    console.print("Run [bold cyan]mlbox deploy[/bold cyan] to provision infrastructure & deploy your model.")
