"""Unit tests for mlbox configuration management."""

from pathlib import Path
import tempfile

from mlbox.config import MLBoxConfig, load_config, save_config


def test_save_and_load_config():
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        config = MLBoxConfig(
            project_id="test-project",
            region="europe-west1",
            template="iris-classifier",
            github_org="test-user",
            github_repo="test-repo",
        )

        saved_file = save_config(config, tmp_path)
        assert saved_file.exists()
        assert saved_file.name == ".mlbox.json"

        loaded = load_config(tmp_path)
        assert loaded is not None
        assert loaded.project_id == "test-project"
        assert loaded.region == "europe-west1"
        assert loaded.template == "iris-classifier"
        assert loaded.github_org == "test-user"


def test_load_config_missing():
    with tempfile.TemporaryDirectory() as tmpdir:
        loaded = load_config(Path(tmpdir))
        assert loaded is None
