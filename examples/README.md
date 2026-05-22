# Examples

These are copy-paste task prompts for using the skill after it is installed.

## Repository Review

```text
Use the supply-chain-guard skill to review this repository's supply-chain posture. Report risks, missing protections, and recommended next actions.
```

## Dependency Review

```text
Use the supply-chain-guard skill to review this repository's current dependencies and lockfiles.
```

## pnpm Hardening Review

```text
Use the supply-chain-guard skill to review this pnpm repository before running pnpm commands. Check the pinned pnpm version, `pnpm-workspace.yaml`, age gate, trust policy, build-script approval, exotic subdependency blocking, and exact save-prefix policy. Report missing project-level protections before installing.
```

## Dependency Change Review

```text
Use the supply-chain-guard skill to review the current manifest and lockfile diff.
```

## AI/ML Artifact Review

```text
Use the supply-chain-guard skill to review this model, dataset, tokenizer, embedding, adapter, fine-tune, or RAG source change. Verify source identity, immutable revision, hash, safe loading format, remote-code behavior, and data-poisoning risk before loading it.
```

## CI And Release Review

```text
Use the supply-chain-guard skill to review this repository's GitHub Actions, release workflows, and publish path.
```

## Incident Triage

```text
Use the supply-chain-guard skill to check whether this repository is affected by [INCIDENT_OR_PACKAGE_NAME].
```

## Full Review

```text
Use the supply-chain-guard skill to perform a full supply-chain review of this repository, including dependencies, lockfiles, package-manager config, AI/ML artifacts, model/dataset/RAG sources, GitHub Actions, release and publish paths, Docker/container files, IaC/deployment config, vendored code, submodules, local development setup, IDE/editor config, MCP config, agent-tooling config, and incident-response readiness. Report prioritized findings, missing protections, and concrete next actions.
```
