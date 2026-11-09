"""mlbox destroy command: clean teardown of all cloud resources."""

from pathlib import Path
import typer
from rich.console import Console

from mlbox.config import load_config
from mlbox.terraform import TerraformRunner

console = Console()


def destroy_project(
    auto_approve: bool = typer.Option(
        False, "--auto-approve", "-y", help="Skip confirmation prompt before tearing down"
    ),
):
    """Tears down all provisioned GCP infrastructure to prevent ongoing costs."""
    cwd = Path.cwd()
    config = load_config(cwd)

    if not config:
        console.print("[yellow]Warning:[/yellow] No .mlbox.json found. Running terraform destroy directly...")

    if not auto_approve:
        confirm = typer.confirm(
            "Are you sure you want to destroy all cloud infrastructure? This cannot be undone.",
            default=False,
        )
        if not confirm:
            console.print("[dim]Aborted by user.[/dim]")
            raise typer.Exit()

    runner = TerraformRunner(cwd)
    if not runner.ensure_installed():
        raise typer.Exit(code=1)

    success = runner.destroy(auto_approve=True)
    if not success:
        console.print("[bold red]Destruction encountered errors.[/bold red]")
        raise typer.Exit(code=1)

    console.print("[bold green]All resources destroyed. Zero continuing cloud spend.[/bold green]")

