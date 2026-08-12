# Attack Patterns and Review Checks

Use this reference when reviewing a dependency change, investigating a named campaign, or checking whether a repository was exposed.

## High-signal suspicious changes

- A patch or minor release published very recently for a popular package.
- A package version whose tarball, integrity hash, or registry source changed unexpectedly.
- A previously released version, tag, branch, dist reference, source reference, provenance subject, or digest that now resolves to different content.
- New or modified `preinstall`, `install`, `postinstall`, `prepare`, `prepack`, `build`, or equivalent lifecycle scripts.
- New or modified import, bootstrap, autoload, framework discovery, plugin, service-provider, source-generation, or startup metadata.
- New `optionalDependencies`, platform-specific packages, or binary downloader packages.
- Newly added Git, tarball, HTTP, file path, or branch-based dependencies.
- Nested manifests or generated files that introduce another package manager, runtime, CI command, hook, or tool config.
- Obfuscated JavaScript, packed/minified installer code, base64 payloads, dynamic `eval`, `Function`, shell command construction, or environment-variable enumeration.
- Code that reads home directories, shell history, `.npmrc`, `.pypirc`, `.netrc`, cloud credentials, SSH keys, kubeconfigs, package-manager tokens, GitHub tokens, CI variables, or password-manager exports.
- Network calls from install-time, build-time, import-time, bootstrap-time, CI, or generated code, especially to paste sites, object storage, newly registered domains, URL shorteners, raw gist URLs, or unknown analytics endpoints.
- Downloaded network bytes that are written, interpreted, imported, executed, persisted, or later consumed by privileged jobs.
- Sudden maintainer additions, ownership transfers, new publishing automation, or repository metadata changes near the suspicious release.
- Package metadata pointing to a repository that does not match the package name, scope, maintainers, or release history.
- New or modified agent/editor instruction files, task definitions, hook configs, MCP/tool configs, local permission files, external config URLs, or hidden Unicode.
- Valid provenance from an unexpected workflow, ref, environment, builder, or repository.
- A package or artifact that used to have stronger trust evidence and now has weaker or missing provenance/signature evidence.
- Privileged release jobs restoring caches or artifacts created by pull request workflows.
- Package-manager-native warnings about blocked young versions, unreviewed build scripts, trust downgrades, ignored builds, or exotic sources.
- Age-gate or script-approval bypass lists growing without documented review.

## A–G generalized surface checks

Apply these checks to the new, changed, generated, installed, or about-to-run surface. They are behavior-based and deliberately avoid campaign package lists.

### A — Package installs

Review manifests, lockfiles, package-manager config, nested manifests, distributed artifact contents, and the exact command that will run. Look for lifecycle/build/prepare hooks, bootstrap or import-time execution, native components, binary downloaders, optional or platform-specific execution paths, Git/tarball/URL sources, custom registries, dependency overrides, generated files, and package-manager changes. A one-shot CLI or generator is an install-and-execute event even when it leaves no manifest entry.

Treat these as high-signal behaviors:

- A new hook, entry point, loader, plugin, service provider, source generator, or startup file executes after scripts were supposedly disabled.
- An optional component runs a payload and then fails, making execution look like a harmless ignored install error.
- A package contains manifests or tooling for another ecosystem; apply that ecosystem's checks before running its build or bootstrap path.
- Downloaded bytes are written to a cache, temporary path, tool directory, or workspace and then interpreted, imported, executed, or consumed by a later privileged job.
- The command uses a floating version, mutable ref, unreviewed source, disabled integrity/TLS controls, or a package-manager policy bypass.

### B — Provenance is not safety

Verify provenance, signatures, attestations, checksums, trusted-publisher identity, and transparency records, but keep origin separate from behavior. Suspicious patterns include:

- Valid provenance for an expected workflow after untrusted code, a poisoned cache, a mutable action, or a compromised builder influenced that workflow.
- A correct package/version label whose resolved URL, source/dist ref, tag target, digest, integrity value, builder, subject, or packed contents changed.
- A release published from the expected identity but from an unexpected step, rerun, event, ref, environment, or failed job.
- A trust downgrade: an artifact family that previously had attestations, signatures, immutable sources, or stronger builders suddenly does not.
- Source, registry metadata, packed artifact, SBOM, and provenance claims that disagree about repository, commit, dependencies, or included files.

Do not clear a finding solely because verification succeeds. Compare the verified artifact with reviewed source and expected release behavior.

### C — GitHub Actions

Review workflow triggers, expressions, checked-out refs, inline commands, actions, reusable workflows, permissions, environments, runners, caches, artifacts, release steps, and post-job behavior. Look for:

- Untrusted pull-request or fork code executing in a base-repository or otherwise privileged context.
- A workflow that checks out an attacker-controlled ref and then installs, builds, tests, generates, or runs it with secrets, write permissions, or base-repository cache scope.
- Cache, artifact, package-store, tool-directory, workspace, or build-output writes from untrusted jobs that privileged jobs later restore or consume.
- External actions or reusable workflows pinned to mutable tags/branches, or nested reusable workflows that weaken the caller's assumptions.
- New or modified `run` blocks that download and execute content, enumerate credentials, request identity tokens, publish, alter repository controls, or suppress useful logs.
- OIDC or other release credentials available before the narrow publish step, requested during unexpected steps, or usable by arbitrary code on the runner.
- Reruns, failed jobs, post-job hooks, or persistent self-hosted runners carrying attacker-controlled state across trust boundaries.

### D — IDE extensions

Review the extension artifact and its dependency graph, not just its marketplace page. Check publisher history, ownership changes, source-repository match, exact version, signature, hashes where available, update channel, extension packs/dependencies, activation events, bundled/minified code, native binaries, install/update scripts, network downloads, and declared capabilities.

Flag extensions that activate broadly or before a relevant file is opened; add tasks, debug profiles, terminals, authentication providers, language servers, or workspace settings; read broad filesystem or browser state; spawn processes; download executable content; silently install companion extensions; switch marketplace/update endpoints; or request access unrelated to their stated purpose. Treat workspace recommendations as untrusted suggestions, not approval to install.

### E — MCP and agent tools

Review local and remote MCP servers, agent plugins, tool manifests, tool descriptions, connection config, and launch wrappers as executable dependencies. Check exact source/version, command and arguments, environment inheritance, working directory, transports and endpoints, authentication flow, update mechanism, available tools/resources/prompts, and approval defaults.

Flag tools that:

- Launch through a floating package runner, remote installer, mutable branch, shell wrapper, or opaque downloaded binary.
- Receive broad environment variables or credential paths through config, or gain shell/filesystem/network/browser/email/memory access beyond the task.
- Present tool descriptions, resources, prompts, errors, or remote content that instruct the agent to weaken policy, reveal local data, run unrelated commands, or expand permissions.
- Auto-approve calls, cross trust domains without a visible boundary, follow redirects to unreviewed hosts, or update independently of the pinned project configuration.
- Persist by editing agent rules, skills, hooks, permissions, startup config, or other tool definitions.

### F — Credential blast radius

Model exposure from what the process could reach, not only what it demonstrably stole. Inventory environment variables, dotfiles, package-manager and SCM auth, SSH material, cloud credentials and metadata services, workload identity/OIDC, cluster credentials, signing keys, password-manager or wallet exports, browser sessions, mounted secrets, CI variables, and registry/release/deploy authority.

Review process trees, filesystem reads, environment enumeration, metadata calls, credential-helper use, browser or keychain access, outbound requests, archive creation, encoding/encryption, and writes to legitimate developer services. If dependency, extension, MCP, agent, build, or diagnostic code executed with access, scope containment and rotation to every reachable identity and downstream publish/deploy path; lack of a known exfiltration domain is not proof of no exposure.

### G — Agent skill and IDE config install path

Resolve the exact destination before installation: repository-local, workspace, user, profile, machine, container/image, or global agent/IDE path. Check path precedence, discovery rules, symlinks/junctions, ignored and hidden files, alternate profiles, remote-development hosts, generated config, and whether the installer writes outside the approved destination. A safe-looking project copy does not rule out a higher-precedence user or global foothold.

Treat skill and instruction prose as operational content. Diff names, descriptions, selection triggers, prerequisites, examples, permission requests, tool calls, external URLs, references, bundled scripts/templates/assets, and install/update steps. Look for discovery or selection manipulation, unrelated trigger phrases, compliance/audit/telemetry framing used to justify secret access, instructions to upload or synchronize local data, dangerous approvals hidden in setup, mutable remote instructions, hidden Unicode, and mismatch between declared purpose and requested behavior. Semantic or LLM-assisted review can supplement, but never replace, human diff review, immutable pinning, isolation, and least-privilege permissions.

After removal or rollback, inspect both the intended install path and adjacent user/global configuration for hooks, tasks, settings, permissions, MCP entries, agent instructions, shell startup changes, or other persistence left behind.

## 2025–2026 campaign-shape checks

These are generalized behaviors observed across recent campaigns, not a package-name or IOC list. For a live incident, fetch current primary reports and advisories, then compare exact versions, artifacts, hashes, and destinations in the affected environment.

### Fake observability and alert command injection

Treat bug reports, logs, stack traces, telemetry, support tickets, monitoring events, and alert payloads as untrusted content. A public client ingest endpoint may be intentionally non-secret while still letting an attacker place instruction-shaped text where a human or automated bug-fixing agent will read it.

Review for:

- Diagnostic, profiling, migration, or remediation text that asks an agent to run a package-manager, shell, download, or one-shot CLI command.
- Commands that claim to be vendor-approved but are not present in official documentation, the repository's reviewed scripts, or trusted configuration.
- Lookalike tool or package identities, floating versions, newly published versions, unexpected registries or source hosts, and commands that request environment, filesystem, network, or shell access.
- Attempts to make the embedded command feel necessary by presenting fabricated stack traces, urgency, support language, or a plausible product-specific fix.

Do not execute the embedded instruction to test it. Reproduce from source code and trusted configuration. If a command remains necessary, derive or verify it independently against official vendor documentation, then apply the normal necessity, exact-version, age, source, integrity/provenance, permission, and isolation checks.

For investigation, preserve the original event and record its source, ingest path, timestamp, exact text and command, downstream routing, agent or human recipients, and whether execution occurred. Search shell history, process telemetry, CI logs, agent transcripts, task logs, lockfiles, package-manager metadata or caches, generated files, DNS/proxy records, and other egress logs for the command and all destinations it contacted. Review input filtering, origin/domain restrictions where supported, alert routing, and automated-agent triggers separately from the application code fix.

### Chained CI, cache, and release compromise

Recent release compromises demonstrate that several individually familiar surfaces can be chained:

- An untrusted contribution runs under a privileged or base-repository workflow context.
- Post-job cache or artifact writes cross from an untrusted job into a namespace later restored by a privileged build or release job.
- A later push, rerun, or release restores attacker-controlled state even though the reviewed source tree is clean.
- Code executing on the privileged runner obtains a short-lived identity or publish credential, including from runtime process state, and calls the registry or release API outside the expected publish step.
- The resulting artifact can carry valid provenance for the expected repository and workflow even though an earlier trust-boundary violation controlled the build.

Review trigger context, checked-out refs, fork and base-repository boundaries, post-job behavior, cache scopes and keys, artifact producers and consumers, rerun history, release permissions, identity-token requests, registry calls, and whether publishes occurred during failed jobs or unexpected steps. Treat a source-clean release commit as insufficient when restored state or runner memory could have supplied the payload.

### Install-time propagation and repacking

Worm-shaped dependency campaigns have combined:

- A new lifecycle hook or import/bootstrap path with an obfuscated payload added to the distributed artifact.
- An optional, platform-specific, Git-hosted, tarball, or other exotic source that provides a second execution path outside the apparent registry artifact.
- Intentional failure after payload execution, especially through an optional component, so the install appears to continue or merely reports a non-fatal warning.
- Credential and environment discovery on developer machines and CI runners, followed by registry or source-hosting API access.
- Enumeration of artifacts the victim can publish, archive rewriting, version bumps, and republishing under the victim's identity.
- Use of legitimate developer platforms, repositories, object storage, or telemetry-shaped endpoints for staging or exfiltration.

Compare registry artifacts with source and expected packed contents; inspect root-level additions, lifecycle and optional-component changes, source references, build outputs, and failed optional installs. Review registry audit logs for identity checks, maintainer/package enumeration, unexpected version creation, and publishes outside the normal release path. A lockfile rollback does not undo stolen credentials, republished artifacts, or changes written elsewhere.

### Developer-tool persistence after dependency cleanup

Check for repository-local and user-level changes to editor tasks, agent settings, MCP/tool configuration, instruction files, hooks, shell startup, scheduled tasks, services, and permission files. A payload can use a dependency install only as initial access, then persist in configuration that executes or steers later developer or agent activity. Review both tracked and untracked files plus relevant user-level configuration before declaring cleanup complete.

### Research basis

- [Primary reporter note on alert-borne command injection](https://x.com/m4rio_eth/status/2062803361078890613)
- [Primary reporter note on the same public-ingest alert pattern](https://x.com/sergeykarayev/status/2062645929979822145)
- [Maintainer postmortem on a chained CI cache and release compromise](https://tanstack.com/blog/npm-supply-chain-compromise-postmortem)
- [Independent analysis of install-time repacking and propagation](https://socket.dev/blog/tanstack-npm-packages-compromised-mini-shai-hulud-supply-chain-attack)
- [Independent analysis of lifecycle execution and trusted-publishing abuse](https://www.aikido.dev/blog/mini-shai-hulud-is-back-tanstack-compromised)
- [Independent analysis of cross-platform secret theft, exfiltration, and republishing](https://socket.dev/blog/antv-packages-compromised)
- [Independent analysis of editor and agent configuration persistence](https://www.aikido.dev/blog/mini-shai-hulud-antv-npm-supply-chain-attack)

## Cross-ecosystem execution and influence checks

Review dependency-controlled files that are new, changed, generated, or about to run or be read. Focus on source-to-sink behavior: what can execute code, load code at startup, persist hooks, alter tool behavior, or steer an agent/editor with filesystem, shell, network, or credential access.

Useful local searches:

```sh
rg -n 'autoload|bootstrap|entry_points|console_scripts|plugin|plugins|provider|providers|service[-_ ]?loader|ServiceLoader|META-INF/services|auto[-_ ]?configuration|spring\\.factories|initializer|init\\b|hook|hooks|codegen|generate|sourceGenerator|build\\.rs|proc_macro' .
rg -n 'curl|wget|Invoke-WebRequest|iwr |fetch\\(|requests\\.|httpx|urllib|reqwest|download|chmod|exec\\(|spawn\\(|subprocess|ProcessBuilder|Runtime\\.getRuntime|eval\\(|Function\\(|import\\(|require\\(|/tmp|mktemp|sys_get_temp_dir|nohup|systemd|crontab|launchctl' .
rg -n 'CLAUDE\\.md|\\.cursorrules|AGENTS\\.md|\\.vscode/tasks\\.json|\\.vscode/settings\\.json|\\.mcp\\.json|mcp\\.json|claude_desktop_config\\.json|\\.claude|\\.cursor|\\.windsurf|\\.git/hooks|pre-commit|post-checkout|post-merge|prompt|instruction|rules|permissions|allow' .
rg -nP '[\x{200B}-\x{200F}\x{202A}-\x{202E}\x{2060}-\x{206F}]' .
```

## JavaScript-specific checks

Search manifests and lockfiles for:

- Lifecycle scripts in `package.json`.
- `optionalDependencies`, `bundleDependencies`, `bundledDependencies`, and `overrides` that change install behavior.
- `git+`, `github:`, `http:`, `https:`, `file:`, `link:`, `workspace:*`, `patch:`, and `portal:` specifiers.
- New `.npmrc`, `.yarnrc`, `.yarnrc.yml`, `.pnpmfile.cjs`, `patches/`, `.pnp.cjs`, or package-manager hook files.
- Lockfile entries with changed `resolved`, `integrity`, `checksum`, `dependencies`, `optionalDependencies`, provenance subject, source reference, or package registry host.

Useful local searches:

```sh
rg -n '"(preinstall|install|postinstall|prepare|prepack|postpack)"|optionalDependencies|bundleDependencies|bundledDependencies' package.json '**/package.json'
rg -n 'git\\+|github:|https?:|file:|link:|patch:|portal:' package.json package-lock.json pnpm-lock.yaml yarn.lock bun.lockb
rg -n 'process\\.env|\\.npmrc|GITHUB_TOKEN|NPM_TOKEN|AWS_|AZURE_|GOOGLE_|KUBECONFIG|id_rsa|\\.ssh|child_process|exec\\(|spawn\\(|eval\\(|Function\\(' .
rg -n 'minimumReleaseAgeExclude|minimumReleaseAgeExcludes|npmPreapprovedPackages|trustPolicyExclude|allowBuilds|trustedDependencies|allowScripts' package.json pnpm-workspace.yaml .yarnrc.yml bunfig.toml deno.json
```

## Python-specific checks

Search manifests and lockfiles for:

- Direct URLs, VCS requirements, editable installs, path dependencies, extras that pull large dependency sets, and custom indexes.
- `setup.py`, `setup.cfg`, `pyproject.toml` build backends, plugin entry points, and native extensions.
- New `pip.conf`, `pip.ini`, `uv.toml`, `poetry.toml`, or index credentials.
- Wheel versus source distribution changes, import-time side effects, and generated startup modules.

Useful local searches:

```sh
rg -n 'git\\+|https?://|--extra-index-url|--index-url|--trusted-host|-e\\s|editable|path\\s*=|url\\s*=' requirements*.txt pyproject.toml poetry.lock uv.lock Pipfile.lock
rg -n 'os\\.environ|subprocess|base64|eval\\(|exec\\(|\\.pypirc|\\.netrc|AWS_|AZURE_|GOOGLE_|GITHUB_TOKEN|NPM_TOKEN|KUBECONFIG|id_rsa|\\.ssh' .
rg -n 'exclude-newer|exclude-newer-package|uploaded-prior-to|extra-index-url|trusted-host|explicit\\s*=\\s*true|tool\\.uv\\.index' pyproject.toml uv.toml requirements*.txt
```

## CI and repository checks

Review:

- Workflows that run installs on pull requests with secrets available.
- New or modified workflow permissions, OIDC configuration, publish jobs, release jobs, and registry login steps.
- Self-hosted runner usage and whether untrusted code can run on persistent machines.
- Package publishing provenance and whether releases can be overwritten or mutated.
- Branch protection or ruleset changes around the suspicious time window.
- Third-party actions or reusable workflows pinned to tags/branches instead of full-length commit SHAs.
- Newly introduced reusable workflows from third-party repositories.
- Cache keys, restore keys, and artifact paths that cross from untrusted pull request jobs into trusted release/deploy jobs.
- Release/tag rewrite behavior in CI dependencies.
- New or modified `run` blocks, especially those that download, write, execute, cache, publish, or read secrets.

Useful local searches:

```sh
rg -n 'pull_request_target|permissions:|id-token:|secrets:|GITHUB_TOKEN|npm publish|pypi|twine|docker login|gh release|actions/checkout|self-hosted' .github/workflows
rg -n 'uses:\\s*[^#\\n]+@((main|master|HEAD|latest|v?[0-9]+(\\.[0-9]+){0,2})\\b|\\$\\{\\{)' .github/workflows
rg -n 'jobs\\.[A-Za-z0-9_-]+\\.uses|uses:\\s*[^\\s]+/.github/workflows/.+@' .github/workflows
rg -n 'actions/cache|cache:|restore-keys|upload-artifact|download-artifact|package-manager-cache' .github/workflows
rg -n 'curl .*\\|.*(sh|bash)|wget .*\\|.*(sh|bash)|Invoke-WebRequest|iwr |iex |Set-ExecutionPolicy' .
```

## IDE and AI-tooling checks

Review new or changed:

- `.vscode/extensions.json`, `.vscode/settings.json`, Open VSX or VSIX manifests, JetBrains plugin config, browser extensions used for development, and extension lockfiles where present.
- `.mcp.json`, `mcp.json`, `claude_desktop_config.json`, `.claude/`, `.cursor/`, `.windsurf/`, agent tool manifests, and local tool permission files.
- Extension manifests containing `extensionPack`, `extensionDependencies`, broad activation events, bundled JavaScript, hidden Unicode, native binaries, or marketplace publisher changes.
- MCP/agent tool configs granting shell execution, broad filesystem access, network access, environment-variable access, or access to credential stores.

Useful local searches:

```sh
rg -n 'extensionPack|extensionDependencies|activationEvents|contributes|main|browser' .vscode '**/package.json' '*.vsixmanifest'
rg -n 'mcpServers|command|args|env|allow|permissions|filesystem|shell|stdio|sse|http' .mcp.json mcp.json claude_desktop_config.json .claude .cursor .windsurf
rg -nP '[\x{200B}-\x{200F}\x{202A}-\x{202E}\x{2060}-\x{206F}]' .
```

## Review result standard

When reporting findings, include:

- exact file and line where the risk appears
- package name, selected version, source URL, and lockfile entry
- applicable A–G surface and the expected versus observed behavior
- verified provenance/integrity facts separately from the safety assessment
- exact extension, MCP/tool, skill, or config identity and installed path when applicable
- whether the finding is known-malicious, suspicious, or expected
- whether install-, bootstrap-, CI-, extension-, MCP-, agent-, or config-driven execution was possible
- which credentials, sessions, mounts, or release/deploy permissions were reachable, not only which were confirmed stolen
