# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in MLOps-in-a-Box, please report it
responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, please email **[INSERT EMAIL]** with:

1. A description of the vulnerability
2. Steps to reproduce the issue
3. The potential impact
4. Any suggested fixes (optional)

### What to expect

- **Acknowledgment** within 48 hours
- **Assessment** within 7 days
- **Fix or mitigation** within 30 days for confirmed vulnerabilities
- **Credit** in the release notes (unless you prefer to remain anonymous)

## Security Best Practices for Users

### Credentials

- **Never** commit service account keys, API keys, or secrets to this repository
- Use [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) for GitHub Actions authentication
- Use `gcloud auth application-default login` for local development
- Store sensitive values in `.env` (which is gitignored); use `.env.example` as a template

### Terraform State

- Remote state is stored in a GCS bucket with default encryption
- Enable [state locking](https://developer.hashicorp.com/terraform/language/settings/backends/gcs) to prevent concurrent modifications
- Restrict access to the state bucket to authorized users only

### Infrastructure

- All service accounts follow least-privilege principles
- VPC is configured with Private Google Access (no public IPs on compute)
- Review `checkov` scan results before applying infrastructure changes

## Dependency Scanning

This project uses:
- **Dependabot** for automated dependency updates
- **GitHub Secret Scanning** to detect accidentally committed secrets
- **Checkov** for infrastructure-as-code security scanning

