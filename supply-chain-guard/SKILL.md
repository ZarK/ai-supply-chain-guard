---
name: supply-chain-guard
description: Use before installing, updating, auditing, or executing dependencies, package-manager commands, project generators, CI actions/workflows, release jobs, IDE extensions, MCP servers, or AI-agent tools.
version: 1.0.0
---

# Supply Chain Guard

**Executive Checklist** (load first for quick decisions):
- Prefer existing code / stdlib over new dependencies
- Use exact versions + preserve lockfiles
- Enforce 7-day (14-day for high-risk) package age gate
- Disable lifecycle scripts by default (`--ignore-scripts`)
- Verify provenance, signatures, source repo, and builder
- Treat package-manager commands, generators, CI actions, IDE extensions, MCP tools as code execution
- Isolate risky installs
- Stop for human approval on high-risk or ambiguous cases
- Follow incident response playbook if exposure suspected

Use this skill for every task that can add, remove, update, install, sync, scaffold, generate, execute, publish, or approve dependencies or dependency-provided tooling. In general project work, keep it available and invoke it as soon as the task touches packages, package managers, CI/release automation, IDE/MCP/agent tooling, or installer scripts.

This skill is a policy and workflow layer. It does not replace package-manager controls, endpoint protection, registry malware feeds, repository rules, code review, secret scanning, or incident response.

## Load deeper guidance when needed

... (keep the rest the same) ...