"""Subprocess wrapper for Terraform commands with rich console output."""

import json
import shutil
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from rich.console import Console

console = Console()


def is_terraform_installed() -> bool:
    """Checks whether the terraform binary is available in PATH."""
    return shutil.which("terraform") is not None


def run_command(cmd: List[str], cwd: Optional[Path] = None) -> Tuple[int, str, str]:
    """Runs a shell command and returns (returncode, stdout, stderr)."""
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(cwd) if cwd else None,
            capture_output=True,
            text=True,
            check=False,
        )
        return proc.returncode, proc.stdout, proc.stderr
    except FileNotFoundError:
        return 127, "", f"Command '{cmd[0]}' not found."
    except Exception as e:
        return 1, "", str(e)


class TerraformRunner:
    def __init__(self, working_dir: Path):
        self.working_dir = working_dir

    def ensure_installed(self) -> bool:
        if not is_terraform_installed():
            console.print(
                "[bold red]Error:[/bold red] Terraform CLI is not installed or not in PATH.\n"
                "Please install Terraform >= 1.6 from: https://developer.hashicorp.com/terraform/install"
            )
            return False
        return True

    def init(self) -> bool:
        console.print("[cyan]Running 'terraform init'...[/cyan]")
        code, stdout, stderr = run_command(["terraform", "init"], cwd=self.working_dir)
        if code != 0:
            console.print(f"[red]terraform init failed:[/red]\n{stderr or stdout}")
            return False
        console.print("[green]Terraform initialized successfully.[/green]")
        return True

    def plan(self, out_file: Optional[str] = "tfplan") -> bool:
        console.print("[cyan]Running 'terraform plan'...[/cyan]")
        cmd = ["terraform", "plan"]
        if out_file:
            cmd.extend(["-out", out_file])
        code, stdout, stderr = run_command(cmd, cwd=self.working_dir)
        if code != 0:
            console.print(f"[red]terraform plan failed:[/red]\n{stderr or stdout}")
            return False
        console.print(stdout)
        return True

    def apply(self, plan_file: Optional[str] = None, auto_approve: bool = False) -> bool:
        console.print("[cyan]Applying Terraform configuration...[/cyan]")
        cmd = ["terraform", "apply"]
        if plan_file and Path(self.working_dir / plan_file).exists():
            cmd.append(plan_file)
        elif auto_approve:
            cmd.append("-auto-approve")

        code, stdout, stderr = run_command(cmd, cwd=self.working_dir)
        if code != 0:
            console.print(f"[red]terraform apply failed:[/red]\n{stderr or stdout}")
            return False
        console.print(stdout)
        console.print("[bold green]Deployment complete![/bold green]")
        return True

    def destroy(self, auto_approve: bool = False) -> bool:
        console.print("[yellow]Destroying Terraform-managed infrastructure...[/yellow]")
        cmd = ["terraform", "destroy"]
        if auto_approve:
            cmd.append("-auto-approve")

        code, stdout, stderr = run_command(cmd, cwd=self.working_dir)
        if code != 0:
            console.print(f"[red]terraform destroy failed:[/red]\n{stderr or stdout}")
            return False
        console.print(stdout)
        console.print("[bold green]All resources destroyed cleanly.[/bold green]")
        return True

    def get_outputs(self) -> Dict[str, str]:
        code, stdout, _ = run_command(["terraform", "output", "-json"], cwd=self.working_dir)
        if code != 0 or not stdout.strip():
            return {}
        try:
            raw = json.loads(stdout)
            return {k: v.get("value", "") for k, v in raw.items()}
        except Exception:
            return {}

