# Changelog

This project uses Git tags and GitHub releases as the source of truth for released versions.

## Unreleased

- Add the named surface review in `SKILL.md` for Package installs, Provenance is not safety, GitHub Actions / CI, IDE extensions, MCP / agent tools, Credential blast radius, and Agent skill / IDE config install path, and keep the detailed checks in the reference files under those names.
- Treat alerts, logs, telemetry, and support content as untrusted instructions and add response guidance for alert-sourced command execution.
- Expand attack and incident guidance for chained CI/cache/release compromise, install-time propagation, trusted-platform exfiltration, and editor/agent configuration persistence without embedding package IOC lists.
- Prefer pinned pnpm for new or genuinely unpinned JavaScript/TypeScript projects while requiring explicit, reviewed migration from established managers.
- Add prompts for alert-triggered fixes, package-manager selection, and the named surface review.
- Add repository ownership and release automation.
- Add npm Trusted Publishing and staged publishing review guidance.
