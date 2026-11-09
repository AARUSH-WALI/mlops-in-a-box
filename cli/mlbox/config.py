"""Configuration management for mlbox CLI."""

import json
from pathlib import Path
from typing import Optional
from pydantic import BaseModel, Field

CONFIG_FILE_NAME = ".mlbox.json"


class MLBoxConfig(BaseModel):
    project_id: str = Field(..., description="GCP Project ID")
    region: str = Field(default="us-central1", description="GCP Region")
    name_prefix: str = Field(default="mlops", description="Naming prefix")
    environment: str = Field(default="dev", description="Environment")
    template: str = Field(default="iris-classifier", description="Model template")
    github_org: Optional[str] = Field(default="", description="GitHub org")
    github_repo: Optional[str] = Field(default="", description="GitHub repo")
    endpoint_id: Optional[str] = Field(default=None, description="Deployed Vertex Endpoint ID")


def get_config_path(directory: Optional[Path] = None) -> Path:
    base = directory or Path.cwd()
    return base / CONFIG_FILE_NAME


def load_config(directory: Optional[Path] = None) -> Optional[MLBoxConfig]:
    path = get_config_path(directory)
    if not path.exists():
        return None
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        return MLBoxConfig(**data)
    except Exception:
        return None


def save_config(config: MLBoxConfig, directory: Optional[Path] = None) -> Path:
    path = get_config_path(directory)
    dump_fn = getattr(config, "model_dump", getattr(config, "dict", None))
    data = dump_fn() if dump_fn else {}
    path.write_text(json.dumps(data, indent=2), encoding="utf-8")
    return path
