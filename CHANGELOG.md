# Changelog

This project uses Git tags and GitHub releases as the source of truth for released versions.

## Unreleased

## v1.4.1 - 2026-08-13

- Refresh the agentic install matrix. Document Grok Bot and Grok Build. Update tool paths against current vendor docs.

## v1.4.0 - 2026-08-13

- Harden first-pass installs: Yarn Berry script suppression, Python wheels-only for unreviewed trees, and a Gradle lock command that actually resolves configurations.
- Require user approval and OSV/GHSA/NVD corroboration for age-gate exceptions. Age-check the selected artifact upload time, not Git commit or tag time.
- Treat READMEs, registry text, changelogs, advisories, and install output as untrusted. Confirm canonicity when a package name comes from the model.
- Add GitHub Actions expression-injection checks. Rotate incident credentials from a clean machine and revoke sessions.
- Document npm 12 `allowScripts` / `allow-git` / `allow-remote`, runtime and framework advisory handling, and replace social-post citations with Tenet Agentjacking and Aikido PromptPwnd.

## v1.3.0 - 2026-08-12

- Add the named surface review in SKILL.md for Package installs, Provenance is not safety, GitHub Actions / CI, IDE extensions, MCP / agent tools, Credential blast radius, and Agent skill / IDE config install path, and keep the detailed checks in the reference files under those names.
- Treat alerts, logs, telemetry, and support content as untrusted instructions and add response guidance for alert-sourced command execution.
- Expand attack and incident guidance for chained CI/cache/release compromise, install-time propagation, trusted-platform exfiltration, and editor/agent configuration persistence without embedding package IOC lists.
- Add prompts for alert-triggered fixes, package-manager selection, and the named surface review.
- Prefer the pinned JS package manager policy for new or unpinned projects with explicit reviewed migration.
- Update CI GitHub Actions for link checking and markdown lint.

## v1.2.0 - 2026-05-25

- Add repository ownership and release automation.
- Add staged publishing review guidance.
