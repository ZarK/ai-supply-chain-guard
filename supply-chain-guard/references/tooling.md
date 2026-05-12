# Tooling

Use this reference when the user asks what tools to run or install. Tools are optional layers; do not make any single provider mandatory.

## Install-time guards

Install-time guards sit between package-manager commands and registries to block known malicious packages and, in some cases, packages that are too new.

- Treat install-time blocking and package-age enforcement as design patterns, not as a recommendation for one provider.
- Options may include open-source registry proxies, hosted package intelligence platforms, endpoint controls, package-manager plugins, or organization-managed artifact repositories.
- Keep this skill's 7-day/14-day package-age policy at the agent decision layer unless the user explicitly chooses otherwise.
- Prefer pinned releases and reviewed installers in high-security environments. Do not pipe remote installer scripts into a shell without explicit approval.
- If naming a specific tool, explain why it fits the user's constraints and mention neutral alternatives when practical.

## Vulnerability and malware scanning

Use more than one data source when the risk justifies it:

- OSV-Scanner for lockfile and SBOM vulnerability scanning against OSV data.
- Platform-native dependency review, vulnerability alerts, and malware alerts where available.
- Registry-native audit tools such as `npm audit`, `npm audit signatures`, `pnpm audit`, `yarn npm audit`, `deno audit`, `pip-audit`, `cargo audit`, `cargo vet`, `bundle audit`, `composer audit`, `dotnet list package --vulnerable`, and ecosystem equivalents.
- Additional package intelligence tools when already available to the user.

Treat scanner output as input to review, not an automatic fix instruction. Do not run broad update commands just because a scanner reports a vulnerability.

## First-party trust and provenance checks

- npm: use `npm audit signatures` where supported to verify registry signatures and provenance attestations for installed packages.
- PyPI: prefer Trusted Publishers and digital attestations for publishing; verify expected publisher identity where tooling supports it.
- JSR/Deno: prefer provenance-capable publishing and `deno audit` where applicable.
- GitHub artifacts: verify consumed attestations with `gh attestation verify` and inspect signer repository/workflow, ref, environment, and artifact digest against policy.
- Composer: use Composer's security blocking / policy configuration where available, in addition to `composer audit`.

Valid provenance is not proof that the code is benign. It only tells you where and how the artifact claims to have been built.

## CI workflow scanners

- Use `zizmor` or an equivalent GitHub Actions security scanner to detect unsafe `pull_request_target`, template injection, excessive permissions, credential persistence, and confusable references.
- Use `actionlint` or an equivalent workflow linter for syntax and common workflow mistakes.
- Treat scanner output as review input, not an automatic fix instruction.

## Dependency-bot cooldown alignment

- Configure dependency bot cooldowns to match the repository's package-age policy where the bot supports it.
- Do not let automated update bots bypass `min-release-age`, `minimumReleaseAge`, `npmMinimalAgeGate`, `minimumDependencyAge`, `exclude-newer`, `--uploaded-prior-to`, or equivalent gates unless the PR is an approved security-fix exception.
- Keep bot PRs small enough for meaningful lockfile and provenance review.

## Project health signals

Use health and provenance signals to prioritize review:

- OpenSSF Scorecard for repository security posture signals.
- Maintainer and publisher history.
- Release cadence and recent ownership changes.
- Signed tags, signed commits, attestations, and trusted publishing.
- SBOMs and package provenance when provided by the project.

Low scores or missing signals are not proof of compromise, but they increase review depth.

## SBOM and artifact inspection

When asked for release or deployment hardening:

- Generate SBOMs with tools such as Syft, CycloneDX generators, package-manager-native export commands, or platform-native SBOM export.
- Scan containers and filesystems with tools such as Trivy, Grype, or equivalent scanners already used by the project.
- Compare SBOMs across releases to detect unexpected dependency additions.

## Running tools safely

- Prefer tools already pinned in the repo.
- If installing a scanner, apply this skill's dependency intake checklist to the scanner itself.
- Run scanners in isolated environments when they must inspect untrusted code.
- Preserve raw outputs for incident response, but avoid committing noisy reports unless the user asked for artifacts.
