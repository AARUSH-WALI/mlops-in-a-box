"""Unit tests for mlbox init command."""

from pathlib import Path
import tempfile
from typer.testing import CliRunner

from mlbox.__main__ import app

runner = CliRunner()


def test_init_command_creates_files():
    with tempfile.TemporaryDirectory() as tmpdir:
        with runner.isolated_filesystem(temp_dir=tmpdir):
            result = runner.invoke(
                app,
                [
                    "init",
                    "--project-id",
                    "my-test-project",
                    "--region",
                    "us-central1",
                    "--no-init-terraform",
                ],
            )
            assert result.exit_code == 0
            assert "Workspace ready" in result.output

            # Verify .mlbox.json exists
            assert Path(".mlbox.json").exists()
            assert Path("terraform.tfvars").exists()

            content = Path("terraform.tfvars").read_text(encoding="utf-8")
            assert 'project_id  = "my-test-project"' in content
            assert 'region      = "us-central1"' in content

