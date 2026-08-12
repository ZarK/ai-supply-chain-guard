# Ecosystem Playbooks

Use this reference when a task touches a specific package manager, lockfile, project generator, or installer. Prefer the project's existing package manager and pinned version. Do not introduce a second manager for convenience.

## Universal flow

1. Detect manifests, lockfiles, toolchain pins, workspaces, and CI install commands.
2. Use frozen or locked install modes for existing dependencies.
3. Disable dependency lifecycle scripts by default when installing or refreshing dependencies.
4. Before adding or upgrading, query registry metadata for exact version, publication time, source repository, integrity, signatures, provenance, and deprecation or malware status.
5. Prefer an older compatible version if the newest version fails the package-age policy.
6. Use native age gates, script approvals, trust policy, and provenance checks where the pinned package-manager version supports them.
7. Review lockfile diffs for unexpected transitive additions, source changes, Git/tarball URLs, script-bearing packages, and registry changes.
8. Review dependency-controlled execution and influence surfaces that are new, changed, generated, or about to run or be read, including lifecycle scripts, import/bootstrap hooks, CI commands, generated files, nested manifests, and agent/editor/tool configuration.

## JavaScript and TypeScript

Detect: `package.json`, `package-lock.json`, `npm-shrinkwrap.json`, `pnpm-lock.yaml`, `yarn.lock`, `.yarnrc.yml`, `bun.lock`, `bun.lockb`, `deno.json`, `deno.lock`, `jsr.json`.

Safe existing installs:

- npm: `npm ci --ignore-scripts`
- pnpm: `pnpm install --frozen-lockfile --ignore-scripts`
- Yarn Classic: `yarn install --frozen-lockfile --ignore-scripts`
- Yarn Berry: `YARN_ENABLE_SCRIPTS=0 yarn install --immutable --immutable-cache --check-cache`. Berry has no `--ignore-scripts`. Use `YARN_ENABLE_SCRIPTS=0` or `--mode=skip-build`. Do not rely on a missing project `enableScripts: false`.
- Bun: `bun install --frozen-lockfile --ignore-scripts`
- Deno: use checked-in `deno.lock`; avoid lockfile refresh unless intentional.

Before adding packages:

- Query npm metadata with `npm view <pkg>@<version> time dist.tarball dist.integrity repository maintainers scripts --json` or the registry API.
- Install exact versions only, for example `npm install --save-exact --ignore-scripts <pkg>@<version>`.
- Use native package-age gates where available: npm `min-release-age` (CLI 11.10.0+), pnpm `minimumReleaseAge`, Yarn `npmMinimalAgeGate`, Bun `minimumReleaseAge`, and Deno `minimumDependencyAge` / `--minimum-dependency-age`.
- Use native script approval where available: npm 12+ `allowScripts` / `npm approve-scripts`, pnpm `approve-builds` / `allowBuilds`, Deno `approve-scripts`, Yarn `enableScripts: false` plus per-package `dependenciesMeta`, and Bun `trustedDependencies` after review. On npm 12+, also review `allow-git` and `allow-remote`. Do not set them to `all` to make CI pass.
- Run provenance/signature checks where supported, such as `npm audit signatures`, but treat valid provenance as identity evidence rather than a safety verdict.
- Treat `npx`, `npm create`, `pnpm dlx`, `yarn dlx`, `bunx`, `deno run`, and generator templates as code execution. Pin exact package versions or immutable URLs before use.
- Inspect `scripts`, `bin`, entry points, loaders, package-manager plugins, framework auto-discovery metadata, `optionalDependencies`, `peerDependenciesMeta`, lifecycle hooks, and native binary download paths.
- Watch lockfiles for registry host changes, tarball URL changes, integrity changes without version changes, provenance subject changes, source/digest reference changes, retargeted Git tags, and newly introduced Git dependencies.
- Before install, look up provenance or attestations from the registry when published (`npm view` provenance fields, registry attestation APIs). "Expected" means the attestation repository and workflow match the registry metadata repository. Absent provenance raises review depth. Downgraded provenance blocks until the user approves.
- If you invented a package name, confirm it is the canonical package before install. Prefer names the codebase already uses.

## Python

Detect: `pyproject.toml`, `requirements*.txt`, `constraints*.txt`, `poetry.lock`, `uv.lock`, `Pipfile.lock`, `environment.yml`, `conda-lock.yml`, `hatch.toml`.

Safe existing installs:

- uv: `uv sync --locked` or `uv sync --frozen`
- pip for unreviewed trees: `pip install --only-binary=:all: --require-hashes -r requirements.txt`. `--require-hashes` alone still executes a correctly hashed sdist build backend.
- pip 26.1+ with upload-time metadata: add `--uploaded-prior-to=P7D` or `P14D` for high-risk surfaces.
- pip without hashes: install only in isolated environments and prefer adding hashes before broad changes.
- Poetry for unreviewed trees: `POETRY_INSTALLER_ONLY_BINARY=:all: poetry sync`. `poetry sync` without only-binary can execute an sdist build backend even when the lock is hashed.
- Pipenv for unreviewed trees: `PIP_ONLY_BINARY=:all: pipenv sync`. Same sdist-build caveat as pip. Prefer `pipenv sync` over `pipenv install` for existing locks.
- rye: unmaintained, no security updates. Flag it and recommend uv.
- Conda: use locked environment files where available; avoid unconstrained solves in privileged environments.

Before adding packages:

- Query PyPI JSON metadata for each selected file's `upload_time_iso_8601`, file hashes, yanked status, project URLs, and classifiers. A later wheel on an old version is a new artifact.
- Pin exact versions with `==` in requirements or exact lock entries.
- Use uv `exclude-newer` / `exclude-newer-package` where appropriate, and map private indexes explicitly to reduce dependency-confusion risk.
- Avoid `setup.py` execution paths, arbitrary build backends, and source builds until reviewed. For unreviewed trees, require wheels only (`--only-binary=:all:` or the poetry/pipenv equivalent).
- Review entry points, plugins, import-time side effects, generated code hooks, startup modules, direct URLs, VCS refs, wheel/sdist changes, and index/source mapping changes.
- Prefer PyPI Trusted Publishers and digital attestations for publishing, but still verify the expected workflow identity and source path.
- Treat `pipx`, `uvx`, `python -m pip`, `poetry run`, and project scaffolding tools as code execution.

## Go

Detect: `go.mod`, `go.sum`, `go.work`, `vendor/`.

Safe existing installs:

- Prefer `go mod download` or normal test/build commands without changing `go.mod` or `go.sum`.
- Use `go mod verify` after dependency changes.
- Avoid broad `go get -u` or toolchain-wide updates.

Before adding modules:

- Pin semantic import versions explicitly, for example `go get example.com/module@v1.2.3`.
- Verify module path ownership, proxy/checksum behavior, `go.sum` changes, `replace` directives, repository tags, and resolved commits.
- Review `init` functions, blank imports, code generators, plugin registration, and build/test commands that can execute dependency code.
- Be cautious with private module configuration, `GONOSUMDB`, `GONOPROXY`, and `GOPRIVATE`; do not disable public checksum verification for public modules.

## Rust

Detect: `Cargo.toml`, `Cargo.lock`, `.cargo/config.toml`.

Safe existing installs:

- Prefer `cargo fetch --locked`, `cargo build --locked`, `cargo test --locked`.
- Avoid `cargo update` unless updating dependencies intentionally.

Before adding crates:

- Query crates.io metadata for `created_at`, repository, owners, features, and yanked status.
- Pin exact versions where risk is high and inspect feature expansion, source changes, checksums, and Git dependencies.
- Treat `build.rs`, proc macros, native linking, and downloaded binaries as high risk.
- Use `cargo vet` or `cargo crev` where the project already uses them.

## JVM: Maven and Gradle

Detect: `pom.xml`, `mvnw`, `.mvn/`, `build.gradle`, `build.gradle.kts`, `settings.gradle`, `gradle.lockfile`, `gradle/verification-metadata.xml`, `gradle/wrapper/gradle-wrapper.properties`.

Safe existing installs:

- Maven: prefer pinned plugin versions, repository governance, checksum fail-closed policy, and Maven Enforcer rules such as `banDynamicVersions`.
- Gradle: use dependency locking and dependency verification metadata for application builds. Write locks with `./gradlew dependencies --write-locks`. In a multi-project build, run that task per subproject. `./gradlew --write-locks` with no task writes nothing and exits 0.
- Do not update wrappers, plugins, or dependency ranges casually.

Before adding dependencies:

- Pin exact `group:artifact:version`; avoid dynamic versions such as `+`, `latest.release`, version ranges, and changing plugin portals without review.
- Review repositories in build files; avoid adding broad public mirrors or untrusted custom repositories.
- Treat Gradle plugins, Maven plugins, annotation processors, service loaders, framework auto-configuration, and generated-code hooks as executable code.

## .NET

Detect: `.csproj`, `.fsproj`, `.vbproj`, `Directory.Packages.props`, `packages.lock.json`, `NuGet.config`, `paket.dependencies`, `paket.lock`.

Safe existing installs:

- `dotnet restore --locked-mode` when lockfiles are present.
- Keep central package management versions exact.

Before adding packages:

- Pin exact versions and trusted package sources.
- Use Package Source Mapping when multiple feeds are configured.
- Review `NuGet.config` for unexpected feeds or embedded credentials.
- Treat analyzers, source generators, MSBuild targets, assembly/module initializers, startup hooks, and native assets as executable code.

## Ruby

Detect: `Gemfile`, `Gemfile.lock`, `.ruby-version`, `.tool-versions`.

Safe existing installs:

- `bundle config set --local deployment true`, `bundle config set --local frozen true`, then `bundle install`.
- Avoid `bundle update` unless intentionally updating.

Before adding gems:

- Pin exact versions when risk is high, check release age, source, authors, and native extensions.
- Review `post_install` hooks, Railties, initializers, plugins, generators, and gems that alter build, deployment, or framework startup behavior.

## PHP

Detect: `composer.json`, `composer.lock`.

Safe existing installs:

- `composer install --no-scripts --no-plugins` for first-pass dependency restoration.
- Run required trusted scripts/plugins only after review.
- Use `composer audit` and Composer policy/security blocking where available.

Before adding packages:

- Pin versions, review Packagist metadata, repository URLs, abandoned status, plugins, autoload changes, branch aliases, VCS/path repositories, and whether old tags or source references were retargeted.
- Before trusting a registry version that resolves through a Git tag, verify the tag commit is on the expected publisher repository, matches the expected tree, and was not retargeted to a fork.
- Treat Composer plugins, scripts, `autoload.files`, framework package discovery, service providers, and generated autoloaders as code execution. `--no-scripts --no-plugins` does not prevent code from running later when `vendor/autoload.php`, a framework, a test runner, or a CLI loads the dependency graph.

## CI actions, reusable workflows, and release automation

Detect: `.github/workflows/`, GitLab CI config, CircleCI config, Buildkite pipelines, reusable workflow references, third-party CI actions, release scripts, cache steps, artifact download/upload steps.

Safe defaults:

- Pin third-party actions and reusable workflows to immutable commit SHAs where the platform supports it.
- Treat tag and branch references as mutable dependency versions.
- Treat new or modified CI `run` blocks as executable dependency code, especially in jobs with write tokens, secrets, OIDC, cache/artifact writes, publish steps, or deploy permissions.
- Avoid privileged triggers (`pull_request_target`, `workflow_run`, `issue_comment`, `pull_request_review`, untrusted `repository_dispatch`) for workflows that check out, install, build, cache, or run untrusted code.
- Never interpolate untrusted `github.event.*` or `github.head_ref` into a `run:` script. Pass the value through `env:` and quote it.
- Treat artifacts and metadata from a `workflow_run` triggering run as untrusted. Do not execute or interpolate them.
- Do not let untrusted pull request jobs write caches or artifacts that privileged release/deploy jobs later restore.
- Prefer clean release installs from reviewed lockfiles over restored mutable caches.
- Use OIDC/trusted publishing with protected environments and tightly scoped publish jobs, but do not treat valid provenance as proof the workflow was safe.

## IDE extensions, MCP servers, and AI-agent tooling

Detect: `.vscode/extensions.json`, `.vscode/settings.json`, Open VSX/VSIX manifests, JetBrains plugin config, browser extensions used for development, `.mcp.json`, `mcp.json`, `claude_desktop_config.json`, `.claude/`, `.cursor/`, `.windsurf/`, `.gitmodules`, `.devcontainer/`, `.envrc`, `mise.toml`, agent tool manifests, and local tool permission files.

Safe defaults:

- Treat extensions, MCP servers, and agent tools as executable dependencies with access to source files, shells, networks, credentials, or editors.
- Pin versions or immutable releases where supported.
- Review extension dependencies, extension packs, activation events, bundled JavaScript, hidden Unicode, native binaries, marketplace publisher changes, project instruction files, hook configs, and external configuration URLs.
- Review tool permissions for shell execution, filesystem access, network access, environment-variable access, and credential-store access.

## Models, datasets, and CDN scripts

Treat model and dataset pulls as code execution:

- Pin an immutable revision or digest. Do not follow a floating `main` or `latest` revision.
- Prefer safetensors over pickle-format weights. Pickle executes code on load.
- Do not set `trust_remote_code=True` without review. That flag runs repository code.
- Apply the same age and source-trust checks to the hub account as to a package publisher.

Treat third-party CDN `<script>` and stylesheet tags as remotely mutable executable code:

- Pin the URL to a version or content digest.
- Require Subresource Integrity (`integrity`) and `crossorigin`, or vendor the file into the repository.
- Treat a CDN domain-ownership change as a trust event.

## Git submodules, devcontainers, and activation hooks

Detect: `.gitmodules`, `.git/modules/`, `.devcontainer/`, `.devcontainer.json`, `devcontainer.json`, `.envrc`, `mise.toml`, `.mise.toml`, direnv and asdf/mise hook files.

- A submodule entry plus a build or test step imports arbitrary code with no package manifest. Pin the submodule to an immutable commit. Review it like a Git dependency.
- `postCreateCommand`, `postStartCommand`, and third-party devcontainer features run code, often as root, when the container is created or reopened. Review the definition before using a container for isolation.
- `.envrc`, mise, and similar activation hooks run on directory entry. Do not enter an untrusted clone with those hooks enabled.

## Runtime and framework advisories

When an advisory targets a language runtime, stdlib, or bundled extension:

- Check the exact runtime version and whether the extension or module is enabled.
- Audit the affected API surface in application code.
- Prefer OS or container package pins and vendor fixed versions.
- Disable unused extensions or modules.

When the advisory is a vendor framework or application security release:

- Identify affected major lines and exact fixed versions.
- Review application-config impact such as auth, middleware, and defaults.
- Use the cooldown-exception path in `SKILL.md` if the fixed version is younger than the age gate.
- Do not run a package-malware indicator hunt as the primary response.

## Containers and OS packages

Detect: `Dockerfile`, `Containerfile`, `docker-compose.yml`, Helm charts, Kustomize, `apk`, `apt`, `dnf`, `brew`, `choco`, `winget`, `scoop`, `nix`, `vcpkg`, `install.sh`.

Safe existing installs:

- Pin base images by digest where practical.
- Avoid `curl | sh`, `latest` tags, broad OS upgrades, and unverified binary downloads.
- Review added repositories, signing keys, install scripts, and downloaded archives.

Before adding images or system packages:

- Verify publisher, digest, signature/attestation where available, and release age.
- Treat package-manager repository additions and GPG key imports as trust-boundary changes.
