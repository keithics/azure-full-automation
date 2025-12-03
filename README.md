# Azure Full Automation

## Table of Contents
1. [Overview](#overview)
2. [Repository Layout](#repository-layout)
3. [Stacks](#stacks)
4. [Scripts](#scripts)
5. [Prerequisites](#prerequisites)
6. [Common Workflows](#common-workflows)
7. [Tips for New Environments](#tips-for-new-environments)

## Overview
This repository contains Terraform and Terragrunt configuration for automating Azure infrastructure. It organizes shared settings, reusable modules, environment specific stacks, and helper scripts so teams can deploy consistent environments with repeatable commands.

## Repository Layout
- **docs/** Reference material and runbooks for deploying stacks, handling Azure provider quirks, and working with Terraform Cloud backends.
- **modules/** Reusable Terraform modules for building blocks such as resource groups, Key Vault, Azure AD applications, logging resources, and supporting components that are shared across stacks.
- **shared/** Terragrunt configuration that defines common locals, remote state settings, Azure subscription references, and outputs consumed by multiple stacks.
- **stacks/** Environment focused Terragrunt stacks. Each stack composes modules and shared settings to deploy a functional area like CI/CD, databases, identity, reporting, or security controls.
- **scripts/** Helper scripts that wrap Terragrunt commands for planning, applying, and exporting outputs. They standardize arguments and keep output artifacts under `.outputs/` for later reuse.
- **root.hcl** Terragrunt root configuration that wires up backends, provider settings, and shared include logic used by stack units.
- **format.sh** Convenience script for running formatting and lint checks across Terraform code.

## Stacks
Each stack under `stacks/` deploys a focused area of the platform. The stack directory contains Terragrunt units that share configuration from `shared/` and invoke modules from `modules/`.

- **cicd** Installs the tooling needed for build and release pipelines, including service principals, container registries, and supporting secrets required for automation agents.
- **db** Provisions database related resources such as servers, firewall rules, and secrets. Use this stack when environments need persistent data stores.
- **entra** Manages identity resources in Entra ID. This includes app registrations, service principals, role assignments, and conditional access settings required by other stacks.
- **reports** Creates reporting and analytics components such as storage accounts, workspaces, and data connections that feed dashboards.
- **security** Establishes baseline security controls including Key Vault, role assignments, diagnostic settings, and policies that harden the environment.

## Scripts
The `scripts/` folder wraps common Terragrunt operations.

- **deploy-stack.sh** Plans or applies a single stack. It expects an action (`plan` or `apply`), an environment name, and a stack name. The script cleans any previous `.terragrunt-stack` artifacts, runs the stack, then exports outputs for each unit to `.outputs/<ENV>/<STACK>/` for reuse by other automation.
- **deploy-all.sh** Runs `deploy-stack.sh` sequentially for a standard set of stacks (entra, reports, security, cicd) with a supplied action and environment. Use this to bring up or refresh the core platform in order.
- **destroy-unit.sh** Removes a specific Terragrunt unit inside a stack. This is useful when tearing down a single component without affecting the rest of the stack.
- **apply-ip-restrictions.sh** Applies network restriction settings for exposed services, aligning IP rules across stacks.
- **assign_workspace_to_project.sh** Associates an analytics workspace to a given project so logs and telemetry land in the correct location.
- **write_backend.sh** Generates or updates backend configuration files using environment specific settings so Terragrunt can store state in the right workspace.
- **functions.sh** Shared shell functions used by other scripts to parse configuration, handle logging, and enforce error handling.
- **new-repo.sh** Bootstraps a new repository from the same conventions, copying templates and initializing Git metadata for rapid project setup.
- **dev/** and **node/** Helper tooling for local development and JSON parsing used by the export process after Terragrunt runs.

## Prerequisites
- Azure CLI authenticated against the target tenant and subscription.
- Terraform CLI configured for your Terraform Cloud or remote state backend if required.
- Terragrunt installed to drive the stack workflows.

## Common Workflows
Plan or apply a single stack within an environment:
- `./scripts/deploy-stack.sh plan <ENVIRONMENT> <STACK>`
- `./scripts/deploy-stack.sh apply <ENVIRONMENT> <STACK>`

Plan or apply the core set of stacks for an environment:
- `./scripts/deploy-all.sh plan <ENVIRONMENT>`
- `./scripts/deploy-all.sh apply <ENVIRONMENT>`

Run formatting before committing to keep Terraform files consistent:
- `./format.sh`

## Tips for New Environments
1. Create an environment config under `environments/<ENV>/config.hcl` with subscription, location, and naming settings.
2. Run `./scripts/deploy-stack.sh plan <ENV> entra` to validate identity resources, then apply once ready.
3. Continue with security and cicd stacks so core controls and pipelines exist before deploying application workloads like `db` or `reports`.
4. Review generated outputs under `.outputs/<ENV>/` when wiring dependencies between stacks, and regenerate them after significant changes.
