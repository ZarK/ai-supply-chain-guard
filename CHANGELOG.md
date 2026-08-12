# Changelog

This project uses Git tags and GitHub releases as the source of truth for released versions.

## Unreleased

- Add the A–G surface review for package installs, provenance limits, GitHub Actions, IDE extensions, MCP/agent tools, credential blast radius, and agent-skill/IDE-config install paths.
- Treat alerts, logs, telemetry, and support content as untrusted instructions and add response guidance for alert-sourced command execution.
- Expand attack and incident guidance for chained CI/cache/release compromise, install-time propagation, trusted-platform exfiltration, and editor/agent configuration persistence without embedding package IOC lists.
- Prefer pinned pnpm for new or genuinely unpinned JavaScript/TypeScript projects while requiring explicit, reviewed migration from established managers.
- Add prompts for alert-triggered fixes, package-manager selection, and A–G reviews.
- Add repository ownership and release automation.
- Add npm Trusted Publishing and staged publishing review guidance.
