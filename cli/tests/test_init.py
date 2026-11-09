"""Unit tests for mlbox init command."""

from typer.testing import CliRunner

from mlbox.__main__ import app

runner = CliRunner()


def test_init_command_creates_files(monkeypatch, tmp_path):
    monkeypatch.chdir(tmp_path)
    result = runner.invoke(
        app,
        [
            "init",
            "--project-id",
            "my-test-project",
            "--region",
            "us-central1",
        ],
    )
    assert result.exit_code == 0
    assert "Workspace ready" in result.output

    # Verify .mlbox.json exists
    assert (tmp_path / ".mlbox.json").exists()
    assert (tmp_path / "terraform.tfvars").exists()

    content = (tmp_path / "terraform.tfvars").read_text(encoding="utf-8")
    assert 'project_id  = "my-test-project"' in content
    assert 'region      = "us-central1"' in content

