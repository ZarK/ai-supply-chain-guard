# Incident Response

Use this reference when a repository may have installed, built, published, or executed a compromised dependency or project generator.

## First response

1. Stop dependency installs, builds, release jobs, and publish jobs in the affected environment.
2. Preserve evidence before cleanup: manifests, lockfiles, package-manager caches if relevant, CI logs, shell history snippets, suspicious package tarballs, process listings, network indicators, and timestamps.
3. Identify the exposure window: first possible install time, CI jobs that ran during that window, developer machines that ran installs, and releases published afterward.
4. Compare exact package names, versions, tarball URLs, hashes, and advisory timestamps against current advisories.
5. Assume any secret available to install/build/import/bootstrap code, CI actions, MCP servers, IDE extensions, agent/editor tooling, or release jobs may be compromised until proven otherwise.
6. Do not assume a package or artifact is safe because it has valid provenance, signatures, or trusted-publishing metadata. Verify the expected workflow/ref/environment and inspect the release path.

## Alert-sourced command execution

If a package-manager, shell, download, one-shot CLI, profiling, or diagnostic command came from an alert, log, stack trace, telemetry event, support ticket, or other external report and may have run:

1. Treat the host or runner as potentially compromised; stop further agent tasks, installs, builds, tests, and releases there.
2. Preserve the original event, source and ingest path, timestamp, exact text and command, routing history, agent transcript or task log, process history, and command output. Do not rerun the command to confirm behavior.
3. Identify every artifact or package name, exact version, source, resolved URL/ref, hash, cache entry, generated file, and process introduced or touched by the command.
4. Inventory the host or runner identity, filesystem mounts, environment variables, credential files, metadata services, network permissions, and publish/deploy authority reachable during execution.
5. Enumerate outbound domains, IPs, URLs, API paths, uploaded content, and downloaded artifacts from DNS, proxy, endpoint, shell, CI, and application telemetry; compare them with current primary reports and advisories rather than a stale embedded IOC list.
6. Rotate or revoke reachable credentials, review SCM/registry/cloud/CI activity for the exposure window, invalidate affected caches and artifacts, and rebuild from clean infrastructure when execution cannot be ruled out.
7. Review the intake system separately: public ingest endpoints are not necessarily secrets, but filtering, supported origin/domain controls, alert routing, and automatic agent triggers should prevent attacker-authored remediation text from becoming trusted instructions.

The final incident note must include the report source, ingest path, timestamp, exact command, artifact or package identity and version, host or runner identity, execution evidence, reachable secrets, outbound indicators, containment, and remaining unknowns.

## Containment

- Remove or pin away from compromised versions and regenerate lockfiles only after deciding the safe target versions.
- Disable or pause publish workflows, package release automation, and deployment jobs until credentials are rotated.
- Revoke or rotate registry tokens, Git hosting tokens, cloud credentials, SSH deploy keys, CI secrets, OIDC trust relationships, kubeconfigs, Vault tokens, package signing keys, AI provider keys, and deployment credentials that were available to affected jobs or machines.
- Invalidate persistent self-hosted runners that executed untrusted installs. Rebuild them from a clean image.
- Rebuild affected self-hosted runner images, dev containers, workstations, or CI runner templates if install-time code may have executed with sensitive access. For hosted runners, discard artifacts/caches and rerun from clean jobs after controls are fixed.
- Invalidate package-manager caches, CI caches, build caches, restored tool directories, and derived artifacts that may contain attacker-controlled files.
- Check for malicious releases, tags, package versions, workflow edits, branch protection changes, deploy keys, webhooks, OAuth apps, personal access tokens, machine users, Git hooks, shell startup files, scheduled jobs, system services, and agent/editor instruction or config changes created during the exposure window.

## Investigation checklist

- Which manifest and lockfile entries pulled the suspicious package?
- Was the dependency direct, transitive, optional, platform-specific, generated, or introduced by a tool?
- Did any install, build, import, bootstrap, test, CI, generator, release, editor, or agent-tool code run or get read?
- Did any agent/editor instruction, hook, task, MCP, local permission, or tool config file change?
- Did any lockfile URL, integrity hash, source reference, dist reference, Git tag target, provenance subject, builder identity, or artifact digest change?
- Which environment variables, token files, credentials, and mounted directories were available?
- Did the environment have publish, release, deploy, cloud, Kubernetes, or repository administration permissions?
- Did the package make outbound network requests? Capture domains, IPs, URLs, downloaded artifacts, local write paths, payload indicators, and whether network bytes were executed or persisted when available.
- Were any downstream artifacts created after exposure: releases, container images, package publishes, binaries, SBOMs, or deployment bundles?
- Did privileged jobs restore caches, artifacts, tool directories, or package-manager stores written by untrusted jobs?
- Did provenance/attestation subjects, workflow identities, builder identities, refs, commits, environments, or triggering events differ from expected release policy?
- Did workflow logs or build artifacts expose secrets, OIDC tokens, publish tokens, environment variables, config files, or credential paths?
- Did SCM, registry, cloud, package-hosting, or CI audit logs show activity during the exposure window?

## 2025–2026 chained campaign triage

Recent campaigns require investigation beyond the changed dependency line:

- **Untrusted-to-privileged automation:** determine whether fork or external-contributor code ran in a base-repository context, including through a privileged pull-request trigger, composite action, reusable workflow, generated command, or post-job step.
- **Cache and artifact bridges:** identify every cache, package store, tool directory, artifact, workspace, or build output written by untrusted jobs and later restored or consumed by release, publish, deploy, or other credentialed jobs. Include reruns and failures.
- **Runtime credentials:** review identity-token requests, runner process access, metadata-service calls, registry logins, and API requests made outside the expected release step. Short-lived credentials and valid provenance do not exclude compromise.
- **Artifact mutation and propagation:** compare published artifacts with source and expected packed contents; review unexpected lifecycle/import hooks, optional or exotic sources, root-level payloads, archive rewrites, version bumps, maintainer enumeration, and publishes under otherwise legitimate identities.
- **Legitimate-platform exfiltration:** review unexpected repository creation, commits, releases, snippets, object uploads, telemetry-like requests, and other writes to trusted developer services as potential staging or exfiltration.
- **Developer-tool persistence:** inspect tracked, untracked, and relevant user-level editor tasks, agent settings, MCP/tool configuration, instruction files, hooks, startup files, scheduled tasks, services, and permission changes made during the exposure window.

Do not close the incident after reverting the lockfile or deprecating a release. Credential theft, downstream publishes, poisoned caches, derived artifacts, and configuration persistence require separate containment and recovery decisions.

## CI cache and provenance triage

During suspected compromise, preserve and review:

- CI cache keys, restore keys, cache scopes, and cache save/restore logs
- artifacts uploaded before release jobs and artifacts downloaded by release jobs
- provenance/attestation subjects, workflow identity, builder identity, ref, commit, environment, triggering event, and artifact digest
- OIDC token permissions, environment protection settings, and registry trusted-publisher bindings
- package-manager caches and stores used by publish jobs
- workflow run attempts and reruns, because later attempts may restore state from earlier compromised jobs

## Recovery

- Restore dependencies to known-good versions, refs, URLs, and hashes, and keep lockfile diffs reviewable.
- Rebuild all releases, container images, packages, binaries, SBOMs, and deployment bundles produced after exposure from clean infrastructure after credential rotation.
- Re-enable CI and release workflows only after least-privilege permissions and dependency checks are in place.
- Add durable controls that would have reduced the incident: frozen installs, disabled lifecycle scripts, dependency review, secret scanning with push protection, package-age policy, install-time malware guard, provenance, isolated runners, and protected release rules.
- Document final known impact, rotated credentials, cleaned artifacts, remaining unknowns, and monitoring follow-up.

## A–G incident record

Use the same surface names as the main skill so handoffs remain complete:

- **A — Package installs:** exact install/restore/generator command, package or tool identity and version, source/ref/URL, manifests and lockfiles, scripts/hooks, artifact contents, caches, outputs, timestamps, and execution evidence.
- **B — Provenance is not safety:** hashes, signatures, attestations, provenance subject, builder, workflow/ref/environment, packed-content comparison, and whether verified release infrastructure was attacker-influenced.
- **C — GitHub Actions:** affected workflows, triggers, refs, jobs, reruns, runners, inline commands, caches, artifacts, permissions, OIDC requests, releases, publishes, and untrusted-to-privileged transitions.
- **D — IDE extensions:** extension identity/version/source, publisher, signature, dependencies, activation, updates, tasks/settings, native or downloaded code, permissions, installed paths, and evidence of execution.
- **E — MCP and agent tools:** server/tool identity and version, launch command, arguments, environment, transport/endpoints, authentication, available capabilities, approvals, configuration changes, and calls made.
- **F — Credential blast radius:** host or runner identity, reachable environment variables, files, mounts, metadata services, sessions, credentials, signing/publish/deploy authority, outbound activity, rotations, and downstream audit results.
- **G — Agent skill and IDE config install path:** intended and actual project/user/global destinations, precedence, symlinks, skill/instruction/config diffs, hooks/tasks/permissions, writes outside scope, persistence found, cleanup, and clean reinstallation evidence.

## Human escalation

Stop and ask the user or incident owner before:

- deleting evidence or package-manager caches
- rotating production credentials that could cause downtime
- revoking organization-wide tokens or deploy keys
- deleting public package versions, releases, tags, or container images
- notifying customers, maintainers, registries, or security teams
