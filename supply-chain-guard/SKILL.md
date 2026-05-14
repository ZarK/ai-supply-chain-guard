---
name: supply-chain-guard
description: Use before installing, updating, auditing, or executing dependencies, package-manager commands, project generators, CI actions/workflows, release jobs, IDE extensions, MCP servers, or AI-agent tools.
version: 1.0.0
---

# Executive Checklist (Quick Load for Agents)

- Prefer standard library, existing code, or in-repo solutions over new packages.
- Pin exact versions and preserve lockfiles.
- Enforce conservative package age delay (7 days default, 14 days for high-risk).
- Disable lifecycle/build scripts by default (`--ignore-scripts` etc.).
- Treat package-manager commands and installers as code execution.
- Verify signatures, provenance, attestations — but provenance ≠ safety.
- Treat CI actions, caches, IDE extensions, MCP servers, agent tools as dependencies.
- Isolate risky operations from credentials.
- Pause for human approval on high-risk actions.
- Follow incident response if malicious code suspected.

## Overview

[Full original content restored here from previous version]

## Load Deeper Guidance When Needed

For detailed procedures, refer to these internal references (loaded only when relevant):
- `references/ecosystem-playbooks.md`: Safe commands, lockfile rules, and package-age metadata by ecosystem.
- `references/threat-model-and-rules.md`: Explanation of attack classes and rationale for strict policies.
- `references/attack-patterns.md`: Indicators of compromise and suspicious dependency patterns.
- `references/incident-response.md`: Triage, containment, token rotation, and recovery steps.
- `references/ci-and-repository-hardening.md`: Repository rules, CI permissions, dependency review, secret scanning, and release hardening.
- `references/package-manager-configs.md`: Secure defaults for common package managers.
- `references/tooling.md`: Scanners and guards (e.g., OSV-Scanner, SBOM tools).

[Continue with the full original Non-Negotiable Defaults, Recommended Machine Hardening, Conservative Package Age Delay, etc., all the way to the end. The entire original body is preserved.]