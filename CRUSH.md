# CRUSH.md

This file provides guidelines for agentic coding agents working in this repository.

## Commands

- **Linting**: `helm lint chart/`
- **Installation**: `helm install my-release chart/`
- **Upgrading**: `helm upgrade my-release chart/`
- **Template rendering**: `helm template chart/ > rendered.yaml`

## Code Style

- **YAML Formatting**: Use 2-space indentation.
- **Naming Conventions**: Follow Kubernetes and Helm naming conventions (e.g., lowercase for resource names).
- **Secrets**: Do not hardcode secrets in `values.yaml`. Use Helm secrets or external secret management.
- **Comments**: Add comments to `values.yaml` to explain non-obvious configurations.
- **Labels and Annotations**: Use standard Kubernetes labels and annotations where applicable.
- **Error Handling**: When creating templates, use `fail` to stop the generation of manifests if a required value is missing.
