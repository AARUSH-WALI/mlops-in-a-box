"""Unit tests for mlbox helper commands (cost, version, status)."""

from typer.testing import CliRunner
from mlbox.__main__ import app

runner = CliRunner()


def test_version_flag():
    result = runner.invoke(app, ["--version"])
    assert result.exit_code == 0
    assert "0.1.0" in result.output


def test_cost_command():
    result = runner.invoke(app, ["cost"])
    assert result.exit_code == 0
    assert "Estimated GCP Monthly Costs" in result.output
    assert "Vertex AI Endpoint" in result.output
    assert "Auto-shutdown is enabled by default" in result.output


def test_status_command():
    result = runner.invoke(app, ["status"])
    assert result.exit_code == 0
    assert "Deployment Status" in result.output
