# Incident Response

Use this reference when a repository may have installed, built, published, or executed a compromised dependency or project generator.

## First response

1. Stop dependency installs, builds, release jobs, and publish jobs in the affected environment.
2. Preserve evidence before cleanup: manifests, lockfiles, package-manager caches if relevant, CI logs, shell history snippets, suspicious package tarballs, process listings, network indicators, and timestamps.
3. Identify the exposure window: first possible install time, CI jobs that ran during that window, developer machines that ran installs, and releases published afterward.
4. Compare exact package names, versions, tarball URLs, hashes, and advisory timestamps against current advisories from OSV, GHSA, NVD, registry advisory APIs, or the vendor security page. Corroborate compromised versions from two independent sources in that tier before any version change.
5. Assume any secret available to install/build/import/bootstrap code, CI actions, MCP servers, IDE extensions, agent/editor tooling, or release jobs may be compromised until proven otherwise.
6. Do not assume a package or artifact is safe because it has valid provenance, signatures, or trusted-publishing metadata. Verify the expected workflow/ref/environment and inspect the release path.
7. Treat synchronized backups, dotfile repositories, migration archives, and configuration exports as potentially poisoned when the compromised host could write to them.

## Untrusted command or download execution

If a package-manager, shell, download, installer, one-shot CLI, profiling, or diagnostic command came from an assistant, search result, advertisement, forum, chat, alert, log, stack trace, telemetry event, support ticket, or other external source and may have run:

1. Treat the host or runner as potentially compromised; stop further agent tasks, installs, builds, tests, and releases there.
2. Preserve the original event, source and ingest path, timestamp, exact text, URL, redirect chain, command, routing history, agent transcript or task log, process history, and command output. Do not revisit the site or rerun the command to confirm behavior from the exposed host.
3. Identify every artifact or package name, exact version, source, resolved URL/ref, hash, cache entry, generated file, and process introduced or touched by the command.
4. Inventory the host or runner identity, filesystem mounts, environment variables, credential files, metadata services, network permissions, and publish/deploy authority reachable during execution.
5. Enumerate outbound domains, IPs, URLs, API paths, uploaded content, and downloaded artifacts from DNS, proxy, endpoint, shell, CI, and application telemetry; compare them with current primary reports and advisories rather than a stale embedded IOC list.
6. Rotate or revoke reachable credentials from a clean machine, sign out active sessions, review SCM/registry/cloud/CI activity for the exposure window, invalidate affected caches and artifacts, and rebuild from clean infrastructure when execution cannot be ruled out.
7. Review the intake system separately: public ingest endpoints are not necessarily secrets, but filtering, supported origin/domain controls, alert routing, and automatic agent triggers should prevent attacker-authored remediation text from becoming trusted instructions.

The final incident note must include the report source, ingest path, timestamp, exact command, artifact or package identity and version, host or runner identity, execution evidence, reachable secrets, outbound indicators, containment, and remaining unknowns.

## Containment

- Remove or pin away from compromised versions and regenerate lockfiles only after deciding the safe target versions.
- Disable or pause publish workflows, package release automation, and deployment jobs until credentials are rotated.
- Rotate credentials from a device that is not in the exposure set, or from a reimaged host. Do not rotate from a workstation or runner that may still be compromised. If the host ran a malicious postinstall, rotating there can hand the attacker the replacements.
- On SCM, registry, cloud, and CI consoles, use "sign out everywhere" or revoke active sessions after rotation. Treat reachable browser sessions, cookies, and password-manager exports as compromised and rotate the underlying accounts.
- Revoke or rotate registry tokens, Git hosting tokens, cloud credentials, SSH deploy keys, CI secrets, OIDC trust relationships, kubeconfigs, Vault tokens, package signing keys, AI provider keys, and deployment credentials that were available to affected jobs or machines.
- Invalidate persistent self-hosted runners that executed untrusted installs. Rebuild them from a clean image.
- Rebuild affected self-hosted runner images, dev containers, workstations, or CI runner templates if install-time code may have executed with sensitive access. For hosted runners, discard artifacts/caches and rerun from clean jobs after controls are fixed.
- Invalidate package-manager caches, CI caches, build caches, restored tool directories, and derived artifacts that may contain attacker-controlled files.
- Check for malicious releases, tags, package versions, workflow edits, branch protection changes, deploy keys, webhooks, OAuth apps, personal access tokens, machine users, Git hooks, shell startup files, scheduled jobs, system services, agent/editor instruction or config changes, and private repositories made public during the exposure window.
- Quarantine synchronized backups and restored configuration. Before the first agent or editor launch on a rebuilt host, review every skill, instruction, rule, hook, task, permission, MCP/tool definition, startup file, and referenced script or asset from outside that host. Restore only known-good files. Recreate files whose origin or integrity is unknown.
- Enumerate other repositories and teams in the same organization that depend on the compromised versions. Use the dependency graph, organization-wide alerts, and internal registry pull logs.

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
- Do published artifacts still match source and expected packed contents, or do root-level payloads, archive rewrites, unexpected version bumps, maintainer enumeration, or publishes under otherwise legitimate identities appear?
- Did the exposure window include writes to legitimate developer platforms — repository creation, commits, releases, snippets, object uploads, or telemetry-shaped requests — that could be staging or exfiltration?
- Did privileged jobs restore caches, artifacts, tool directories, or package-manager stores written by untrusted jobs?
- Did provenance/attestation subjects, workflow identities, builder identities, refs, commits, environments, or triggering events differ from expected release policy?
- Did workflow logs or build artifacts expose secrets, OIDC tokens, publish tokens, environment variables, config files, or credential paths?
- Did SCM, registry, cloud, package-hosting, or CI audit logs show activity during the exposure window?
- Did install-time code invoke a locally installed agent CLI or a permission-bypass flag?
- Were private repositories made public during the exposure window?
- Do user or system package-manager configs (`~/.npmrc`, `~/.yarnrc.yml`, `pip.conf`, `pip.ini`, uv, cargo, NuGet, credential helpers) now point at a new registry, proxy, scoped registry, or `authToken`?
- Which other organization consumers install the same compromised versions?

## CI cache and provenance triage

During suspected compromise, preserve and review:

- whether fork or external-contributor code ran in a base-repository context, including through a privileged pull-request trigger, composite action, reusable workflow, generated command, or post-job step
- CI cache keys, restore keys, cache scopes, and cache save/restore logs
- artifacts uploaded before release jobs and artifacts downloaded by release jobs
- provenance/attestation subjects, workflow identity, builder identity, ref, commit, environment, triggering event, and artifact digest
- OIDC token permissions, environment protection settings, and registry trusted-publisher bindings
- identity-token requests, runner process access, metadata-service calls, registry logins, and API requests made outside the expected release step, because short-lived credentials and valid provenance do not exclude compromise
- package-manager caches and stores used by publish jobs
- workflow run attempts and reruns, because later attempts may restore state from earlier compromised jobs

## Recovery

Do not close the incident after reverting the lockfile or deprecating a release. Credential theft, downstream publishes, poisoned caches, derived artifacts, and configuration persistence require separate containment and recovery decisions.

- Restore dependencies to known-good versions, refs, URLs, and hashes, and keep lockfile diffs reviewable.
- Rebuild all releases, container images, packages, binaries, SBOMs, and deployment bundles produced after exposure from clean infrastructure after credential rotation.
- Re-enable CI and release workflows only after least-privilege permissions and dependency checks are in place.
- Add durable controls that would have reduced the incident: frozen installs, disabled lifecycle scripts, dependency review, secret scanning with push protection, package-age policy, install-time malware guard, provenance, isolated runners, and protected release rules.
- Document final known impact, rotated credentials, cleaned artifacts, remaining unknowns, and monitoring follow-up.
- Report findings using the surface names defined in `SKILL.md` so handoffs stay complete.

## Human escalation

Stop and ask the user or incident owner before:

- deleting evidence or package-manager caches
- rotating production credentials that could cause downtime
- revoking organization-wide tokens or deploy keys
- deleting public package versions, releases, tags, or container images
- notifying customers, maintainers, registries, or security teams
