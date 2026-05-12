# CI and Repository Hardening

Use this reference when asked to harden a repository, CI pipeline, release workflow, or organization settings.

## Repository controls

- Require pull requests before merge and protect default and release branches.
- Require status checks that include tests, dependency review, secret scanning or equivalent, and relevant code scanning.
- Require review from code owners for dependency manifests, lockfiles, CI workflows, release scripts, package-manager config, and infrastructure credentials.
- Require signed commits or verified branch rules where practical.
- Prevent force pushes and branch deletion on protected branches.
- Restrict who can edit workflows, environments, deploy keys, webhooks, package settings, and release jobs.
- Use security policies and private vulnerability reporting channels for public projects.

## Dependency controls

- Enable dependency inventory, vulnerability alerts, malware alerts where available, and dependency review for pull requests.
- Require dependency review as a PR gate for manifests, lockfiles, CI workflow files, reusable workflow references, third-party actions, container build definitions, and package-manager config.
- Require lockfile changes to be included with manifest changes.
- Block dependency changes that introduce unpinned versions, mutable URLs, untrusted registries, mutable CI action refs, reusable workflow refs, or lifecycle scripts without review.
- Prefer automated dependency update PRs that are small, grouped by ecosystem/risk, and reviewed before merge.

## Secret controls

- Enable secret scanning and push protection where available.
- Add custom secret patterns for internal tokens, private registries, package publish tokens, deployment keys, and cloud account formats.
- Do not expose secrets to untrusted pull request workflows.
- Prefer short-lived OIDC credentials over long-lived cloud keys, registry tokens, and deploy keys.
- Keep publish tokens separate from install tokens and give them the smallest possible scope.
- Keep secrets out of dependency install jobs unless the install itself strictly requires them.

## CI permissions

- Set default workflow token permissions to read-only.
- Grant write permissions per job only where required.
- Use environment protection rules for production deploys and package publishing.
- Avoid `pull_request_target` or equivalent privileged fork events for workflows that check out, install, build, cache, or execute untrusted code. If unavoidable, do not check out the pull request head/merge ref, do not run package-manager commands, do not restore shared caches, and grant no write token or OIDC permission.
- Pin third-party actions and reusable workflows to full-length commit SHAs. A tag or branch is mutable and should be reviewed like a floating dependency version.
- Avoid persistent self-hosted runners for untrusted code. Use ephemeral runners or isolated job environments.
- Clear package-manager caches after confirmed compromise and avoid sharing writable caches between trusted and untrusted jobs.

## Cache and artifact trust boundaries

- Never let untrusted pull request code write caches or artifacts that privileged base-branch, release, publish, or deploy jobs can later restore.
- Do not share package-manager caches across fork PR jobs and privileged jobs unless the cache is read-only, content-addressed, and scoped by trusted ref/event.
- Release and publish jobs should prefer clean dependency installs from reviewed lockfiles over restoring mutable caches.
- Treat caches, build artifacts, generated files, tool directories, and restored package-manager stores as executable inputs.
- Disable package-manager caches in publish jobs where practical, especially for registry trusted-publishing workflows.

## Provenance and attestation policy

- Require provenance, signatures, or artifact attestations where registries and build platforms support them.
- Do not treat valid provenance as a malware verdict. Valid provenance can still describe malicious output from a compromised legitimate workflow.
- Verify provenance against an expected policy: repository, workflow file, protected ref or tag, protected environment, builder identity, triggering event, and artifact digest.
- Release jobs must be clean, isolated, and protected from untrusted PR code, poisoned caches, restored artifacts, mutable third-party actions, and unreviewed reusable workflows.
- Verify consumed attestations, not just produced attestations. For GitHub artifact attestations, use `gh attestation verify` and inspect the predicate when policy decisions depend on it.

## Release and publishing hardening

- Use trusted publishing, provenance, attestations, and immutable releases where supported by the package registry and hosting platform.
- Separate build, test, sign, and publish credentials.
- Require human approval or protected environments before publishing packages and production artifacts.
- Prefer trusted publishing/OIDC over long-lived registry automation tokens, with OIDC permission granted only to the publish job.
- For npm publishing, prefer trusted publishing where available, require 2FA and disallow legacy publish tokens after migration where feasible, and disable package-manager caches in publish jobs unless there is a documented reason.
- For PyPI publishing, prefer Trusted Publishers, job-level `id-token: write`, protected environments, and default digital attestations from the official publishing flow where available.
- Verify package contents before publishing: no secrets, unexpected generated files, test fixtures with credentials, or local config files.
- Generate SBOMs for release artifacts where useful and attach them to releases.

## Pull request review checklist

For every dependency or CI change, answer:

- Does this change alter the dependency graph, lockfile, install behavior, registry, or executable lifecycle hooks?
- Does any new code run during install, build, test, release, or deployment?
- Does the workflow expose secrets or write tokens to code from forks or untrusted branches?
- Can untrusted jobs write caches or artifacts consumed by privileged jobs?
- Are third-party actions and reusable workflows pinned to immutable refs?
- Is provenance valid for the expected workflow/ref/environment, and is the release path itself trustworthy?
- Are versions pinned and old enough under the package-age policy?
- Can the same result be achieved with an existing dependency or standard library?
