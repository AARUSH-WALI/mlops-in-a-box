# Contributing to MLOps-in-a-Box

First off, thank you for considering contributing! Every contribution, whether it's fixing a typo, improving docs, or adding a new module, is valued.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Commit Convention](#commit-convention)
- [Pull Request Process](#pull-request-process)
- [Issue Labels](#issue-labels)

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create a branch** from `main` for your changes
4. **Make your changes** with tests
5. **Submit a pull request**

Look for issues labeled [`good first issue`](../../labels/good%20first%20issue) for beginner-friendly tasks with clear steps.

## Development Setup

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6
- [Python](https://www.python.org/downloads/) >= 3.10
- [tflint](https://github.com/terraform-linters/tflint)
- [checkov](https://www.checkov.io/1.Welcome/Quick%20Start.html) (`pip install checkov`)
- (Optional) [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) for testing against GCP

### Setup

```bash
# Clone your fork
git clone https://github.com/<your-username>/mlops-in-a-box.git
cd mlops-in-a-box

# Install the CLI in development mode
cd cli
pip install -e ".[dev]"
cd ..

# Validate Terraform modules
cd modules/bootstrap
terraform init
terraform validate
cd ../..

# Run linters
tflint --recursive
checkov --directory modules/

# Run CLI tests
pytest cli/tests/
```

## How to Contribute

### Terraform Modules

- Each module lives in `modules/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`, and `README.md`
- All variables must have descriptions and sensible defaults where appropriate
- All outputs must have descriptions
- Add a `terraform test` file in `tests/terraform/` for new modules
- Run `terraform fmt` before committing

### Python CLI

- CLI code lives in `cli/mlbox/`
- Follow [PEP 8](https://peps.python.org/pep-0008/) style
- Add tests in `cli/tests/` for new commands
- Use type hints throughout
- Use [Typer](https://typer.tiangolo.com/) conventions for CLI commands

### Documentation

- Update `README.md` if your change affects usage
- Update `docs/ARCHITECTURE.md` if your change affects architecture
- Add inline comments for non-obvious Terraform or Python logic

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
[optional footer]
```

### Types

| Type | Purpose |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `test` | Adding or fixing tests |
| `chore` | Maintenance (CI, deps, tooling) |
| `refactor` | Code change that doesn't fix a bug or add a feature |

### Scopes

`bootstrap`, `network`, `iam`, `registry`, `storage`, `vertex`, `monitoring`, `budget`, `cli`, `ci`, `docs`

### Examples

```
feat(vertex): add endpoint autoscaling configuration
fix(cli): handle missing terraform binary gracefully
docs(readme): add cost estimate table
test(iam): add WIF provider validation test
chore(ci): upgrade tflint to v0.50
```

## Pull Request Process

1. Ensure your PR targets the `main` branch
2. Fill out the PR template completely
3. Make sure CI passes (lint, test, build)
4. Request a review from the maintainer
5. PRs are squash-merged to keep a clean history

### PR Checklist

- [ ] I have read the [CONTRIBUTING](CONTRIBUTING.md) guide
- [ ] My code follows the project's style guidelines
- [ ] I have added tests for my changes
- [ ] I have updated documentation as needed
- [ ] All existing tests pass
- [ ] My commit messages follow the conventional commit format

## Issue Labels

| Label | Description |
|-------|-------------|
| `good first issue` | Beginner-friendly with clear steps |
| `bug` | Something isn't working |
| `enhancement` | New feature request |
| `documentation` | Docs improvement |
| `help wanted` | Extra attention needed |
| `terraform` | Related to Terraform modules |
| `cli` | Related to the mlbox CLI |
| `ci` | Related to GitHub Actions workflows |

## Questions?

Open a [Discussion](../../discussions) or comment on the relevant issue. We're happy to help!

