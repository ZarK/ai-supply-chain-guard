# Incident Response

Use this reference when a repository may have installed, built, published, or executed a compromised dependency or project generator.

## First response

1. Stop dependency installs, builds, release jobs, and publish jobs in the affected environment.
2. Preserve evidence before cleanup: manifests, lockfiles, package-manager caches if relevant, CI logs, shell history snippets, suspicious package tarballs, process listings, network indicators, and timestamps.
3. Identify the exposure window: first possible install time, CI jobs that ran during that window, developer machines that ran installs, and releases published afterward.
4. Compare exact package names, versions, tarball URLs, hashes, and advisory timestamps against current advisories.
5. Assume any secret available to install/build scripts, CI actions, MCP servers, IDE extensions, or release jobs may be compromised until proven otherwise.
6. Do not assume a package or artifact is safe because it has valid provenance, signatures, or trusted-publishing metadata. Verify the expected workflow/ref/environment and inspect the release path.

## Containment

- Remove or pin away from compromised versions and regenerate lockfiles only after deciding the safe target versions.
- Disable or pause publish workflows, package release automation, and deployment jobs until credentials are rotated.
- Revoke or rotate registry tokens, Git hosting tokens, cloud credentials, SSH deploy keys, CI secrets, OIDC trust relationships, kubeconfigs, Vault tokens, package signing keys, and deployment credentials that were available to affected jobs or machines.
- Invalidate persistent self-hosted runners that executed untrusted installs. Rebuild them from a clean image.
- Rebuild affected self-hosted runner images, dev containers, workstations, or CI runner templates if install-time code may have executed with sensitive access. For hosted runners, discard artifacts/caches and rerun from clean jobs after controls are fixed.
- Invalidate package-manager caches, CI caches, build caches, restored tool directories, and derived artifacts that may contain attacker-controlled files.
- Check for malicious releases, tags, package versions, workflow edits, branch protection changes, deploy keys, webhooks, OAuth apps, personal access tokens, and machine users created during the exposure window.

## Investigation checklist

- Which manifest and lockfile entries pulled the suspicious package?
- Was the dependency direct, transitive, optional, platform-specific, generated, or introduced by a tool?
- Did any lifecycle script run?
- Which environment variables, token files, credentials, and mounted directories were available?
- Did the environment have publish, release, deploy, cloud, Kubernetes, or repository administration permissions?
- Did the package make outbound network requests? Capture domains, IPs, URLs, and payload indicators when available.
- Were any downstream artifacts created after exposure: releases, container images, package publishes, binaries, SBOMs, or deployment bundles?
- Did privileged jobs restore caches, artifacts, tool directories, or package-manager stores written by untrusted jobs?
- Did provenance/attestation subjects, workflow identities, builder identities, refs, commits, environments, or triggering events differ from expected release policy?
- Did workflow logs or build artifacts expose secrets, OIDC tokens, publish tokens, environment variables, config files, or credential paths?
- Did SCM, registry, cloud, package-hosting, or CI audit logs show activity during the exposure window?

## CI cache and provenance triage

During suspected compromise, preserve and review:

- CI cache keys, restore keys, cache scopes, and cache save/restore logs
- artifacts uploaded before release jobs and artifacts downloaded by release jobs
- provenance/attestation subjects, workflow identity, builder identity, ref, commit, environment, triggering event, and artifact digest
- OIDC token permissions, environment protection settings, and registry trusted-publisher bindings
- package-manager caches and stores used by publish jobs
- workflow run attempts and reruns, because later attempts may restore state from earlier compromised jobs

## Recovery

- Restore dependencies to known-good versions and keep lockfile diffs reviewable.
- Rebuild all releases, container images, packages, binaries, SBOMs, and deployment bundles produced after exposure from clean infrastructure after credential rotation.
- Re-enable CI and release workflows only after least-privilege permissions and dependency checks are in place.
- Add durable controls that would have reduced the incident: frozen installs, disabled lifecycle scripts, dependency review, secret scanning with push protection, package-age policy, install-time malware guard, provenance, isolated runners, and protected release rules.
- Document final known impact, rotated credentials, cleaned artifacts, remaining unknowns, and monitoring follow-up.

## Human escalation

Stop and ask the user or incident owner before:

- deleting evidence or package-manager caches
- rotating production credentials that could cause downtime
- revoking organization-wide tokens or deploy keys
- deleting public package versions, releases, tags, or container images
- notifying customers, maintainers, registries, or security teams
