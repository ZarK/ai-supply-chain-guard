# Attack Patterns and Review Checks

Use this reference when reviewing a dependency change, investigating a named campaign, or checking whether a repository was exposed.

## High-signal suspicious changes

- A patch or minor release published very recently for a popular package.
- A package version whose tarball, integrity hash, or registry source changed unexpectedly.
- New or modified `preinstall`, `install`, `postinstall`, `prepare`, `prepack`, `build`, or equivalent lifecycle scripts.
- New `optionalDependencies`, platform-specific packages, or binary downloader packages.
- Newly added Git, tarball, HTTP, file path, or branch-based dependencies.
- Obfuscated JavaScript, packed/minified installer code, base64 payloads, dynamic `eval`, `Function`, shell command construction, or environment-variable enumeration.
- Code that reads home directories, shell history, `.npmrc`, `.pypirc`, `.netrc`, cloud credentials, SSH keys, kubeconfigs, package-manager tokens, GitHub tokens, CI variables, or password-manager exports.
- Network calls from install-time scripts, especially to paste sites, object storage, newly registered domains, URL shorteners, raw gist URLs, or unknown analytics endpoints.
- Sudden maintainer additions, ownership transfers, new publishing automation, or repository metadata changes near the suspicious release.
- Package metadata pointing to a repository that does not match the package name, scope, maintainers, or release history.
- Generated files or lockfile entries that introduce a second package manager.
- Valid provenance from an unexpected workflow, ref, environment, builder, or repository.
- A package or artifact that used to have stronger trust evidence and now has weaker or missing provenance/signature evidence.
- Privileged release jobs restoring caches or artifacts created by pull request workflows.
- Package-manager-native warnings about blocked young versions, unreviewed build scripts, trust downgrades, ignored builds, or exotic sources.
- Age-gate or script-approval bypass lists growing without documented review.

## JavaScript-specific checks

Search manifests and lockfiles for:

- Lifecycle scripts in `package.json`.
- `optionalDependencies`, `bundleDependencies`, `bundledDependencies`, and `overrides` that change install behavior.
- `git+`, `github:`, `http:`, `https:`, `file:`, `link:`, `workspace:*`, `patch:`, and `portal:` specifiers.
- New `.npmrc`, `.yarnrc`, `.yarnrc.yml`, `.pnpmfile.cjs`, `patches/`, `.pnp.cjs`, or package-manager hook files.
- Lockfile entries with changed `resolved`, `integrity`, `checksum`, `dependencies`, `optionalDependencies`, or package registry host.

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
rg -n '[\\u200B-\\u200F\\u202A-\\u202E\\u2060-\\u206F]' .
```

## Review result standard

When reporting findings, include:

- exact file and line where the risk appears
- package name, selected version, source URL, and lockfile entry
- whether the finding is known-malicious, suspicious, or expected
- whether install-time execution was possible
- whether credentials or release permissions may have been exposed
