"""Main Typer entrypoint for the mlbox CLI."""

import typer
from mlbox import __version__
from mlbox.commands import (
    init_project,
    deploy_project,
    destroy_project,
    show_status,
    estimate_costs,
    rollback_model,
)

app = typer.Typer(
    name="mlbox",
    help="One command to deploy a monitored ML model on GCP Vertex AI with CI/CD and cost guardrails.",
    add_completion=False,
)

# Register subcommands
app.command("init", help="Bootstrap a new MLOps project workspace")(init_project)
app.command("deploy", help="Deploy infrastructure and models to Vertex AI")(deploy_project)
app.command("destroy", help="Tear down all cloud resources to stop spend")(destroy_project)
app.command("status", help="Show live status of deployed models and endpoints")(show_status)
app.command("cost", help="Estimate monthly and hourly cloud infrastructure costs")(estimate_costs)
app.command("rollback", help="Revert traffic to a previous model deployment version")(rollback_model)


@app.callback(invoke_without_command=True)
def main_callback(
    version: bool = typer.Option(
        False, "--version", "-v", help="Show mlbox version and exit", is_eager=True
    ),
):
    if version:
        typer.echo(f"mlbox version {__version__}")
        raise typer.Exit()


def main():
    app()


if __name__ == "__main__":
    main()

