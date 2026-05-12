---
name: supply-chain-guard
description: Use before installing, updating, auditing, or executing dependencies, package-manager commands, project generators, CI actions/workflows, release jobs, IDE extensions, MCP servers, or AI-agent tools.
---

# Supply Chain Guard

Use this skill for every task that can add, remove, update, install, sync, scaffold, generate, execute, publish, or approve dependencies or dependency-provided tooling. In general project work, keep it available and invoke it as soon as the task touches packages, package managers, CI/release automation, IDE/MCP/agent tooling, or installer scripts.

This skill is a policy and workflow layer. It does not replace package-manager controls, endpoint protection, registry malware feeds, repository rules, code review, secret scanning, or incident response.

## Load deeper guidance when needed

Keep this file active for every dependency-related task. Load these references only when the task needs their detail:

- `references/ecosystem-playbooks.md`: exact safe commands, lockfile rules, and package-age metadata by ecosystem.
- `references/attack-patterns.md`: compromise indicators and suspicious dependency patterns to search for.
- `references/incident-response.md`: suspected compromise triage, containment, token rotation, and recovery.
- `references/ci-and-repository-hardening.md`: repository rules, CI permissions, dependency review, secret scanning, and release hardening.
- `references/package-manager-configs.md`: durable secure defaults for common package managers.
- `references/tooling.md`: optional scanners and guards such as install-time blockers, OSV-Scanner, OpenSSF Scorecard, SBOM tools, and container scanners.

## Non-negotiable defaults

- Prefer the standard library, existing dependencies, or in-repo code over adding a package.
- Treat every package provider and transport the same: npm, npx, pnpm, pnpm dlx, Yarn Classic, Yarn Berry, yarn dlx, Corepack, Bun, bunx, Deno, JSR, uv, pip, pip-tools, pipenv, poetry, hatch, rye, conda, cargo, go modules, Maven, Gradle, Kotlin DSL, NuGet, Paket, CocoaPods, Carthage, Swift Package Manager, Homebrew, MacPorts, Nix, Chocolatey, winget, Scoop, MSIX/App Installer, PowerShell Gallery, vcpkg, Git URLs, tarballs, container images, IDE/editor extensions, browser extensions used for development, MCP servers, AI-agent tools, and project generators.
- Treat CI actions, reusable workflows, workflow templates, build caches, build artifacts, and release automation as dependencies. Pin third-party actions and reusable workflows to immutable full-length commit SHAs where the platform supports it; review tag or branch references like floating package versions.
- Never install `latest`, floating ranges, unpinned Git branches, or unverified tarballs for new dependencies.
- Pin exact versions and preserve/update the lockfile intentionally.
- Never disable security checks, provenance/signature checks, lockfile checks, or TLS verification to make an install work.
- Never run dependency lifecycle/build scripts from newly introduced packages until the package/version has passed the checks below. Use `--ignore-scripts` or the package-manager equivalent when available.
- Treat package-manager commands, project generators, and one-line installers as code execution. Do not run them from an untrusted working directory or with broad credentials present.
- Treat signatures, provenance, trusted publishing, and attestations as identity and integrity signals, not proof that code is safe. Verify the expected repository, workflow, ref, environment, builder, and artifact digest, then still inspect dependency, workflow, cache, and release behavior.

## Recommended machine hardening

When helping a user set up a workstation or CI runner, recommend layered controls before dependency work:

- Consider install-time malware blocking, registry proxying, or package intelligence controls where appropriate for the user's environment.
- Prefer pinned releases and reviewed installers for any security tool. Do not pipe remote installer scripts into a shell without explicit user approval.
- Set secure package-manager defaults in user and project config where supported: exact saved versions, lifecycle scripts disabled by default, frozen/locked installs, and checked-in lockfiles.
- Do risky installs and dependency triage in an isolated dev container, Codespace, VM, or short-lived runner with minimal mounted files and scoped credentials.
- Keep long-lived publish tokens, cloud credentials, SSH keys, and production secrets out of local shells and dependency install jobs whenever possible.
- Use repository rules, signed commits, required pull requests, required status checks, dependency review, code scanning, secret scanning with push protection, vulnerability/malware alerts, and provenance/signature checks where the platform supports them.
- If the user asks for setup commands, load `references/tooling.md` and `references/package-manager-configs.md`.

## Conservative package age delay

- Default minimum age for any newly introduced package version: **7 full days since publication/upload/release**. This is an organization policy and may be stricter than package-manager defaults.
- Prefer **14 days** for runtime, privileged, build-tooling, CI/CD, auth, crypto, networking, installer, postinstall, native binary, or transitive-heavy packages.
- Where supported, enforce this policy with native package-manager age gates as well as manual review. Load `references/package-manager-configs.md` for current configuration examples.
- If a package is younger than the required delay, choose an older compatible version that satisfies the requirement.
- If no compatible version satisfies the delay, do not install it automatically. Explain the block and request explicit user approval before proceeding.
- If publication time cannot be verified from registry/API metadata, treat the package as untrusted and do not install it automatically.

## Cooldown exceptions

Urgent security fixes may bypass the package-age delay only with explicit justification. Document the advisory ID, affected versions, exact fixed version, why no older fixed version is available, scanner/advisory evidence, the narrow package-manager-specific bypass, and post-install lockfile/script/provenance review. Never lower or disable the global age gate silently.

## Required dependency intake checklist

Before adding or upgrading any dependency, verify and document the result in your working notes/final summary:

1. **Need:** why the dependency is necessary and why existing code/deps are insufficient.
2. **Identity:** exact package name, ecosystem, registry/source URL, selected exact version, and lockfile impact.
3. **Age:** selected version publication/upload/release time meets the 7-day minimum, or 14-day preference for high-risk cases.
4. **Source trust:** repository URL matches package metadata, recent maintainers/releases look plausible, and the package is not an obvious typo-squat or namespace confusion.
5. **Execution risk:** install/build/postinstall scripts, native binaries, prebuilt downloads, and code generation are reviewed before execution.
6. **Integrity:** lockfile hashes/checksums/signatures/provenance are preserved or verified when the ecosystem supports them.
7. **Scope:** dependency is added to the narrowest correct scope (`dev`, optional, workspace package, extras group, etc.).

## Active incident workflow

When the user asks about a named attack, compromised package set, malware campaign, or suspicious dependency:

1. Fetch current advisories from primary or reputable sources instead of relying on memory or a stale embedded list.
2. Compare the repository's manifest and lockfile entries against exact compromised package names, versions, tarball URLs, Git URLs, and integrity hashes.
3. Search for known campaign indicators such as unexpected lifecycle hooks, new Git-hosted dependencies, injected `optionalDependencies`, obfuscated install-time JavaScript, unknown binary downloads, credential enumeration, package tarball rewrites, CI action tag rewrites, cache poisoning, or new AI-agent/MCP/IDE tooling permissions.
4. If exposure is possible, stop all installs/builds in that environment, preserve evidence, remove the compromised versions, rotate potentially exposed tokens, invalidate CI credentials, and review recent publish/release activity before resuming work.
5. Document exact matches, non-matches, dates checked, advisory URLs, and remediation steps in the final summary.

For concrete search patterns, containment, and recovery steps, load `references/attack-patterns.md` and `references/incident-response.md`.

## Existing-project install policy

For normal installs in existing projects, avoid dependency graph changes:

- npm: prefer `npm ci --ignore-scripts`; only use `npm install` when intentionally updating the lockfile.
- pnpm: prefer `pnpm install --frozen-lockfile --ignore-scripts`.
- Yarn Classic: prefer `yarn install --frozen-lockfile --ignore-scripts`; do not run `yarn upgrade` unless intentionally updating.
- Yarn Berry/Modern: prefer `yarn install --immutable --immutable-cache --check-cache`; keep `.yarnrc.yml`, `.pnp.cjs`, `.yarn/cache`, and `yarn.lock` changes intentional.
- Corepack: do not auto-activate a floating package-manager version; respect the pinned `packageManager` field or pin Corepack-prepared versions explicitly.
- Bun: prefer `bun install --frozen-lockfile --ignore-scripts` where supported.
- Deno/JSR: prefer checked-in lockfiles (`deno.lock`) and exact `jsr:`/`npm:` specifiers; do not refresh the lock unless intentionally changing dependencies.
- uv: prefer `uv sync --locked` or `uv sync --frozen` depending on project policy; do not refresh the lock unless intentionally changing dependencies.
- pip/requirements/pip-tools: prefer hash-checked installs (`--require-hashes`) when hashes are available; keep pinned requirements files authoritative.
- poetry/pipenv/hatch/rye/conda: prefer locked/frozen/sync modes and do not refresh lockfiles or solve to newer packages unless intentionally changing dependencies.
- .NET/NuGet/Paket: prefer locked restore (`dotnet restore --locked-mode` where available), exact `PackageReference`/central package versions, and trusted package sources only.
- Java/Kotlin Maven: prefer dependency lock or checksum verification where configured; avoid changing `pom.xml` ranges or plugin versions without explicit intent.
- Java/Kotlin Gradle: prefer dependency locking / verification metadata (`gradle.lockfile`, `verification-metadata.xml`) and exact plugin/library versions.
- CocoaPods/Carthage/SPM: prefer `pod install`, existing `Cartfile.resolved`, and `Package.resolved` with exact package pins/resolved files; avoid `pod update`, `carthage update`, or resolver refresh unless intentional.
- Homebrew/MacPorts/Nix/Chocolatey/winget/Scoop/PowerShell Gallery/vcpkg: avoid broad upgrade commands; install explicit formula/cask/package IDs and versions where supported, and verify source URLs/checksums/manifests/derivations.

If scripts are required for a known trusted package already in the lockfile, run the minimal necessary rebuild command after reviewing what will execute.

## Project secure defaults

When allowed to update project configuration, prefer durable defaults over relying on every command being remembered:

- npm project `.npmrc`: `ignore-scripts=true` and `save-exact=true` unless the project has documented exceptions.
- Yarn Berry `.yarnrc.yml`: `enableScripts: false`, `enableImmutableInstalls: true`, and exact semver prefix policy.
- GitHub Actions and other CI: install with scripts disabled by default, use least-privilege tokens, avoid exposing secrets to pull requests, and require dependency/security checks before merge.
- Commit documented exceptions for packages that truly need lifecycle scripts; rebuild only those packages after review.
- For exact config snippets, load `references/package-manager-configs.md`.

## Adding packages safely

- Query registry metadata before install. Examples: npm registry `time`, PyPI JSON `upload_time_iso_8601`, NuGet registration `published`, Maven Central `timestamp`, Gradle Plugin Portal metadata, CocoaPods specs commit/tag time, Carthage/SPM Git tag or release time, Homebrew formula/cask history, winget/Chocolatey/Scoop manifest commit time, PowerShell Gallery publish time, crates.io `created_at`, GitHub release `published_at`, container image digest timestamps/provenance.
- Install exact versions only, e.g. npm/pnpm/bun `pkg@x.y.z`, uv/pip `pkg==x.y.z`, NuGet `PackageReference Version="x.y.z"`, Maven/Gradle `group:artifact:x.y.z`, CocoaPods `pod 'Name', 'x.y.z'`, SPM/Carthage resolved commits/tags, Homebrew bundle pins or versioned formulae where available, winget/Chocolatey/Scoop/PowerShell Gallery explicit versions where supported, cargo `crate@x.y.z`, Go module version tags, image digests.
- Use package-manager flags that reduce surprise where available: `--save-exact`, `--ignore-scripts`, frozen/locked mode, offline/cache verification, signatures/provenance/audit commands.
- Re-run lockfile-aware install/test/build after changes and inspect unexpected transitive additions.

## Baseline review records

- Do not create marker files or policy artifacts in a user's repository unless they ask for a baseline review, hardening PR, or durable documentation.
- When asked for a baseline review, record the detected ecosystems, manifests, lockfiles, package-manager versions, risky findings, commands run, dates checked, and unresolved risks in the requested format.
- A baseline review does **not** waive checks for new dependency additions, upgrades, lockfile rewrites, new package managers, or new executable tooling.
- If a repository has multiple package roots/workspaces, cover all detected package roots before calling the baseline complete.

## High-risk source rules

- Avoid Git URL, branch, tarball, curl-pipe-shell, and binary-download dependencies. If unavoidable, pin to an immutable commit or digest and verify provenance.
- Avoid packages with recent ownership transfer, sudden maintainer expansion, unusual postinstall scripts, obfuscated/minified source in source packages, or metadata/repository mismatch.
- For CLIs and project generators (`npm create`, `npx`, `pnpm dlx`, `yarn dlx`, `bunx`, `deno run`, `uvx`, `pipx`, `dotnet tool install`, `mvn archetype:generate`, `gradle init`, `cargo install`, `brew install`, `choco install`, `winget install`, `scoop install`, `Install-Module`, `vcpkg install`, etc.), apply the same age, pinning, and script-execution rules before running generated code.

## When blocked

Do not bypass this guard silently. Either choose an older verified version, implement without the new dependency, or stop and ask for explicit approval with the exact risk and package/version named.
