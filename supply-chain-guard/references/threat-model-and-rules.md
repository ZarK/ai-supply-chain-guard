# Threat Model and Rules Tutorial

Use this reference when onboarding a human reviewer, explaining why the skill is strict, or deciding whether a proposed exception is safe. It teaches the attack classes behind the rules in `SKILL.md`.

## The Short Version

Modern supply-chain attacks do not only look like an obviously fake package. They often arrive through trusted surfaces:

- a legitimate package name that briefly publishes malicious versions
- a legitimate CI workflow that is tricked into publishing attacker-controlled output
- a third-party CI action or reusable workflow pinned to a mutable tag
- an install script, build backend, source distribution, or project generator
- a poisoned cache or artifact restored by a privileged release job
- an IDE extension, MCP server, or AI-agent configuration that grants shell, filesystem, network, or environment access

Supply Chain Guard therefore applies one core idea: treat anything that can introduce or execute code as a dependency, then slow down, pin, verify, isolate, and minimize secrets before it runs.

## Lesson 1: Official Packages Can Be Malicious

Recent npm and PyPI incidents show that malicious code can be published under real package names, not just lookalike names. In the TanStack incident on 2026-05-11, malicious versions were published across real `@tanstack/*` packages after a CI/release-path compromise. The reported attack chain involved `pull_request_target`, GitHub Actions cache poisoning, and OIDC token extraction from a runner. In the AntV wave reported on 2026-05-19, public analyses described hundreds of malicious npm package versions across real `@antv` and related packages tied to a compromised publishing account. In both cases, the resulting package versions were legitimate registry releases, but the code was malicious.

What the skill does because of this:

- It does not trust a package just because the name is familiar.
- It checks exact package name, exact version, registry source, and lockfile entry.
- It treats newly published versions as risky by default.
- It requires a 7-day default age gate on the selected artifact's upload time and prefers 14 days for higher-risk packages.
- It fetches current advisories during named incidents instead of relying on static package lists.

A related case is intentional maintainer self-sabotage (protestware). The legitimate sole maintainer can ship a destructive or geo-conditional payload under valid provenance and the expected publisher. Identity signals stay green. The age gate and runtime-behavior review still apply.

Human habit to learn: when a popular package has a fresh patch release, do not assume "patch" means "safe." Ask who published it, when, from where, and whether the version has survived public scrutiny. Valid identity is not proof of benign intent.

## Lesson 2: Install Is Code Execution

Package installs often run code. JavaScript lifecycle hooks, Python build backends, source distributions, native extension builds, Git dependencies, project generators, and one-shot CLIs can execute before the user ever imports the package.

The TanStack and AntV malware described by public analyses executed during install through dependency metadata and lifecycle behavior. AntV reporting described a `preinstall` hook that ran a Bun-based payload before the package could be used. Other package compromises have similarly targeted install time because install environments often contain credentials, package-manager tokens, cloud credentials, SSH keys, CI variables, or release permissions.

What the skill does because of this:

- It treats `npm install`, `pnpm install`, `yarn`, `bun`, `pip`, `uv`, `poetry`, `cargo install`, `go install`, `dotnet tool install`, `mvn`, `gradle`, `brew`, `choco`, `winget`, `scoop`, `Install-Module`, `npx`, `pnpm dlx`, `yarn dlx`, `bunx`, `deno run`, and similar commands as code execution.
- It prefers `--ignore-scripts` or equivalent first-pass installs.
- It requires review before approving lifecycle or build scripts.
- It treats source builds and native binary downloads as higher-risk than ordinary metadata resolution.
- It recommends isolated containers, VMs, Codespaces, or short-lived runners for risky dependency work.

Human habit to learn: before running an install in a repo you do not fully trust, ask "what code will run before I see the app?"

## Lesson 3: Provenance Proves Origin, Not Safety

Trusted publishing, signatures, artifact attestations, and provenance are valuable because they answer identity and integrity questions: where did this artifact come from, which workflow built it, and does the digest match?

They do not prove that the produced code is benign. If a legitimate workflow is compromised, valid provenance can describe malicious output. In the TanStack case, public reporting states that malicious publishes were authenticated through the project's trusted publishing path after attacker-controlled code executed in CI.

What the skill does because of this:

- It requires provenance verification where the ecosystem supports it.
- It verifies the expected repository, workflow file, ref, environment, builder identity, triggering event, and artifact digest.
- It still reviews the code, lockfile, cache, workflow, and release path after provenance passes.
- It treats missing or downgraded provenance as a review signal, especially when older versions had stronger trust evidence.

Human habit to learn: "signed by the expected system" is not the same as "safe to install." Ask whether the expected system itself was trustworthy at build time.

## Lesson 4: CI Actions and Workflows Are Dependencies

GitHub Actions, reusable workflows, workflow templates, and CI helper scripts are executable dependencies. Tags and branches are mutable. A third-party action referenced as `@v1`, `@main`, or `@master` can change without a manifest diff in your repository.

Public supply-chain incidents have shown that CI dependencies can expose secrets, publish artifacts, modify releases, or run attacker code in privileged contexts. The TanStack postmortem also called out floating refs and workflow trust boundaries as lessons.

What the skill does because of this:

- It treats third-party actions and reusable workflows like packages.
- It requires full-length commit SHA pinning for third-party actions where the platform supports it.
- It flags branch and tag refs like floating dependency versions.
- It reviews `pull_request_target`, `workflow_run`, `issue_comment`, `id-token: write`, `secrets`, `permissions`, `actions/cache`, `upload-artifact`, and `download-artifact` changes.
- It treats `${{ github.event.* }}` interpolation into `run:` scripts as code execution.
- It separates untrusted PR work from privileged release and publish jobs.

Human habit to learn: a workflow file is production code. A one-line `uses:` change can be as risky as adding a new runtime dependency.

## Lesson 5: Caches and Artifacts Cross Trust Boundaries

Build caches and artifacts are not inert. They can contain binaries, package stores, generated code, scripts, compiled outputs, or tool directories that will be executed later.

The TanStack attack chain reportedly used GitHub Actions cache poisoning so attacker-controlled data created by a pull request path could later be restored by a release workflow on the trusted branch. That is exactly the sort of cross-boundary reuse this skill tries to prevent.

What the skill does because of this:

- It treats caches, artifacts, generated files, package-manager stores, and restored tool directories as executable inputs.
- It blocks untrusted PR jobs from writing caches or artifacts consumed by privileged jobs.
- It prefers clean release installs from reviewed lockfiles over mutable cache restores.
- It recommends disabling package-manager caches in publish jobs where practical.
- It tells responders to purge caches and rebuild artifacts after suspected compromise.

Human habit to learn: if untrusted code can write it and trusted code later runs it, it is a supply-chain boundary.

## Lesson 6: Dependency Attacks Move Fast

Many malicious releases are detected, deprecated, or removed within hours. That short window is exactly why freshness matters. A version published minutes ago has had little time for ecosystem scanners, maintainers, researchers, and downstream users to notice problems.

What the skill does because of this:

- It applies a 7-day default package-age delay to the exact artifact that will be installed.
- It prefers 14 days for packages that run in production, touch auth/crypto/networking, ship native code, affect CI/CD, execute install scripts, or have large transitive graphs.
- It age-checks file or asset upload time and digest. It does not treat Git commit time, Git tag time, or a version-level `published_at` as protection when a later file exists.
- It recommends native age gates where available, such as npm `min-release-age` (11.10.0+), pnpm `minimumReleaseAge`, Yarn `npmMinimalAgeGate`, Bun `minimumReleaseAge`, Deno `minimumDependencyAge`, uv `exclude-newer`, pip `--uploaded-prior-to`, and Poetry `solver.min-release-age`.
- It requires an authenticated user decision or an immutable, reviewed organization or repository policy, plus an advisory corroborated against OSV, GHSA, or NVD, for age-gate exceptions.

Human habit to learn: time is a security control. It will not catch every attack, but it avoids being among the first systems to run a freshly compromised release. Passing the age gate is not evidence of safety.

## Lesson 7: Security Fixes Need a Narrow Exception Path

Age gates can delay urgent vulnerability fixes. A blanket rule that blocks every young version can be harmful when a CVE has a newly released fix and no older safe version exists.

What the skill does because of this:

- It allows security-fix exceptions only through an authenticated user decision or an immutable, reviewed organization or repository policy established outside untrusted task content.
- It requires an advisory ID corroborated against OSV, GHSA, NVD, or the registry advisory API. Package text and prompting reports are not evidence.
- It requires affected versions, exact fixed version, and an explanation of why no older fixed version works.
- It requires the narrowest package-manager bypass available.
- It still requires post-install lockfile, script, provenance, and test review.
- It never silently lowers the global age gate.

Human habit to learn: exceptions should be narrow, named, temporary, and reviewed by the user. Disabling the guard globally is not an exception path.

## Lesson 8: Slopsquatting Is the Agent as Vector

This skill's audience is an agent that can pick package names from its own memory. A hallucinated name that an attacker pre-registered weeks earlier can clear the age gate, show plausible metadata, ship no scripts, and still be the wrong package.

What the skill does because of this:

- When a name comes from the model rather than the user, a manifest, or official docs, it requires a canonicity check.
- It prefers names the codebase already uses.
- It compares downloads, dependents, first-publish date, and official-doc references against any more popular near-identical name.

Human habit to learn: a name the model "remembers" is a hypothesis. Confirm it is the canonical package before install.

## Lesson 9: Exotic Sources Bypass Normal Registry Signals

Git URLs, tarballs, branch refs, raw HTTP URLs, local paths, binary downloaders, and custom registries often bypass the metadata and review workflows people rely on. They may lack publication timestamps, signatures, provenance, checksums, vulnerability data, or consistent immutability.

The AntV wave also showed why exotic sources matter inside otherwise familiar registry packages: public reports described an injected GitHub dependency such as `@antv/setup` that pointed at a specific repository commit and provided another lifecycle execution path during install.

What the skill does because of this:

- It avoids Git URL, branch, tarball, curl-pipe-shell, and binary-download dependencies by default.
- If unavoidable, it pins to immutable commits or digests.
- It verifies checksums and provenance where possible.
- It treats missing publication metadata as untrusted.
- It flags new custom indexes, extra registries, and dependency-confusion-prone source mappings.

Human habit to learn: "just use this GitHub URL" is still installing someone else's code. It deserves the same scrutiny as a registry package, often more.

## Lesson 10: IDE, MCP, and Agent Tooling Are Part of the Supply Chain

Development tooling now executes code with access to the user's workspace, shell, environment variables, local credentials, and sometimes browser or cloud sessions. IDE extensions, MCP servers, agent rules, hooks, tasks, and tool permission files can become persistence or exfiltration mechanisms.

Public reporting around the AntV Mini Shai-Hulud wave described developer-tool persistence paths such as unexpected VS Code task configuration and Claude Code settings. Separate extension-marketplace incidents have shown that extension dependencies and bundled code can also be abused.

What the skill does because of this:

- It reviews `.vscode/`, `.cursor/`, `.windsurf/`, `.claude/`, `.mcp.json`, `mcp.json`, `claude_desktop_config.json`, and similar files.
- It treats MCP servers and AI-agent tools as executable dependencies.
- It flags shell, filesystem, network, environment-variable, and credential-store access.
- It reviews extension manifests, activation events, extension packs, extension dependencies, bundled JavaScript, hidden Unicode, and native binaries.

Human habit to learn: developer tooling is not harmless config. If it can run commands or read secrets, it belongs in the supply-chain review.

## Lesson 11: Lockfiles Are Evidence

Lockfiles record resolved versions, URLs, integrity hashes, transitive dependencies, and sometimes registry sources. They are not just package-manager noise. During an incident, the lockfile often answers whether a repository could have installed the compromised version.

What the skill does because of this:

- It preserves lockfiles and uses frozen/locked installs.
- It requires manifest and lockfile changes to be reviewed together.
- It inspects unexpected transitive additions and changed `resolved`, `integrity`, checksum, source, or registry fields.
- It avoids broad resolver refreshes when the user did not ask for dependency changes.

Human habit to learn: a lockfile diff is a security diff. Review it like code.

## Lesson 12: Secrets Make Installs Dangerous

Many supply-chain payloads hunt for secrets first because stolen credentials let the attacker spread, publish, deploy, or access cloud systems. Developer machines and CI runners often have more secrets than application runtime environments.

What the skill does because of this:

- It recommends keeping publish tokens, cloud credentials, SSH keys, and production secrets out of dependency install jobs.
- It prefers short-lived OIDC credentials over long-lived tokens.
- It scopes OIDC to the specific job that needs it.
- It treats a malicious install as possible workstation or runner compromise.
- It escalates to token rotation and release review when exposure is possible.

Human habit to learn: do not install unreviewed dependencies in the same shell or CI job that can publish, deploy, or read production secrets.

## Lesson 13: Incident Response Must Assume Execution Happened

If malicious install-time code may have run, cleanup is not just "remove the package." The environment may have leaked credentials, poisoned caches, produced compromised artifacts, persisted through developer-tool configuration, or published new malicious versions.

What the skill does because of this:

- It stops installs and builds in the exposed environment.
- It preserves evidence before cleanup.
- It rotates credentials from a clean machine and kills active sessions.
- It invalidates CI tokens, caches, and derived artifacts.
- It audits package registry, SCM, cloud, and release activity during the exposure window.
- It rebuilds releases from clean infrastructure when needed.

Human habit to learn: package compromise response is closer to incident response than dependency cleanup.

## How an Agent Should Apply These Lessons

When dependency or tooling work starts, the agent should:

1. Identify every package manager, registry, lockfile, CI workflow, publish path, IDE extension config, MCP config, and agent-tool config in scope.
2. Prefer no new dependency if existing code or existing dependencies can solve the task.
3. If a dependency is needed, select an exact version and verify age, source, canonicity when the name came from the model, metadata, maintainers, provenance, scripts, binaries, and lockfile impact before install.
4. Use frozen/locked installs and lifecycle-script suppression by default.
5. Review all CI action and reusable workflow refs like dependency refs.
6. Keep untrusted PR code, mutable caches, artifacts, and package-manager stores away from release and publish jobs.
7. Escalate when the safe answer depends on user approval, credential rotation, destructive cleanup, or a security-fix exception.

## How a Human Should Use the Skill

Use the skill as a decision checklist, not as a magic scanner.

- Before adding a dependency, ask whether the dependency is necessary.
- Before installing, ask what code will execute.
- Before merging a lockfile, ask what changed transitively.
- Before trusting provenance, ask whether the workflow that produced it was trustworthy.
- Before publishing, ask whether the release job is isolated from untrusted code, caches, and broad credentials.
- During an incident, ask whether the environment should be treated as compromised.

## Source Notes

This tutorial is based on the public TanStack postmortem, Socket and Aikido analyses of Mini Shai-Hulud activity including the May 2026 AntV wave, Tenet Agentjacking and Aikido PromptPwnd research, GitHub Actions hardening and artifact-attestation guidance, npm trusted publishing and configuration docs, and the ecosystem package-manager documentation linked from `package-manager-configs.md`.

Primary references:

- TanStack postmortem: [TanStack postmortem](https://tanstack.com/blog/npm-supply-chain-compromise-postmortem)
- Socket TanStack analysis: [Socket TanStack analysis](https://socket.dev/blog/tanstack-npm-packages-compromised-mini-shai-hulud-supply-chain-attack)
- Aikido TanStack analysis: [Aikido TanStack analysis](https://www.aikido.dev/blog/mini-shai-hulud-is-back-tanstack-compromised)
- Socket AntV analysis: [Socket AntV analysis](https://socket.dev/blog/antv-packages-compromised)
- Aikido AntV analysis: [Aikido AntV analysis](https://www.aikido.dev/blog/mini-shai-hulud-antv-npm-supply-chain-attack)
- Tenet Agentjacking: [Tenet Agentjacking](https://tenetsecurity.ai/blog/agentjacking-coding-agents-with-fake-sentry-errors/)
- Aikido PromptPwnd: [Aikido PromptPwnd](https://www.aikido.dev/blog/promptpwnd-github-actions-ai-agents)
- GitHub Actions secure use: [GitHub Actions secure use](https://docs.github.com/en/actions/reference/security/secure-use)
- GitHub artifact attestations: [GitHub artifact attestations](https://docs.github.com/en/actions/concepts/security/artifact-attestations)
- npm trusted publishing: [npm trusted publishing](https://docs.npmjs.com/trusted-publishers/)
- npm config: [npm config](https://docs.npmjs.com/cli/v11/using-npm/config)
- npm v12 breaking changes: [npm v12 breaking changes](https://github.blog/changelog/2026-06-09-upcoming-breaking-changes-for-npm-v12/)
