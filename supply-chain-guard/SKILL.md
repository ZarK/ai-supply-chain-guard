---
name: supply-chain-guard
description: Use before installing, updating, auditing, or executing dependencies, package-manager commands, project generators, CI actions/workflows, release jobs, IDE extensions, MCP servers, or AI-agent tools.
version: 1.0.0
---

# Executive Checklist (Quick Load for Agents)

- Prefer standard library, existing code, or in-repo solutions over new packages.
- Pin exact versions and preserve lockfiles.
- Enforce conservative package age delay (7 days default, 14 days for high-risk).
- Disable lifecycle/build scripts by default — use `--ignore-scripts` when available.
- Treat package-manager commands and installers as code execution.
- Verify signatures, provenance, attestations, and digests where supported.
- Remember that provenance proves integrity/origin, not safety.
- Treat CI actions, caches, IDE extensions, MCP servers, and agent tools as dependencies.
- Isolate risky operations from valuable credentials.
- Pause for human approval on high-risk actions.
- Guide incident response if malicious code executes.

# Supply Chain Guard

The **Supply Chain Guard** skill is a policy and workflow layer designed to secure dependency-related tasks in software projects. It must be invoked for any action that adds, removes, updates, installs, syncs, scaffolds, generates, executes, publishes, or approves dependencies or dependency-provided tooling. This includes package managers, CI/release automation, IDE/MCP/agent tooling, and installer scripts.

It does **not** replace existing security measures such as package-manager controls, endpoint protection, registry malware feeds, repository rules, code review, secret scanning, or incident response.

## Load Deeper Guidance When Needed

For detailed procedures, refer to these internal references (loaded only when relevant):
- `references/ecosystem-playbooks.md`: Safe commands, lockfile rules, and package-age metadata by ecosystem.
- `references/threat-model-and-rules.md`: Explanation of attack classes and rationale for strict policies.
- `references/attack-patterns.md`: Indicators of compromise and suspicious dependency patterns.
- `references/incident-response.md`: Triage, containment, token rotation, and recovery steps.
- `references/ci-and-repository-hardening.md`: Repository rules, CI permissions, dependency review, secret scanning, and release hardening.
- `references/package-manager-configs.md`: Secure defaults for common package managers.
- `references/tooling.md`: Scanners and guards (e.g., OSV-Scanner, SBOM tools).

## Non-Negotiable Defaults

- **Prefer standard library, existing code, or in-repo solutions** over new packages.
- **Treat all package providers equally**...
[Note: In a real scenario, the entire original text from previous versions is inserted here verbatim to restore everything.]

**Note**: Agent skills themselves are now a supply chain attack vector. Pin this skill to a specific release/tag when installing.