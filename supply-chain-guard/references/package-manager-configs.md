# Package Manager Configs

Use this reference when the user asks for durable project or workstation defaults. Apply changes only when they match the project's workflow and after explaining tradeoffs.

## Native package-age gates

Where supported, enforce the 7-day/14-day age policy in package-manager configuration as well as in agent review:

- npm 11.10.0+: `.npmrc` `min-release-age=7` or `min-release-age=14` in days. Do not combine with `before`. npm ignores unknown keys, so on 11.0–11.9 the key is a no-op. After writing it, read the value back (`npm config get min-release-age`) and confirm a younger version is blocked on a dry run.
- pnpm v10.16+/v11: `pnpm-workspace.yaml` `minimumReleaseAge: 10080` for 7 days or `20160` for 14 days in minutes.
- Yarn Berry 4.12+: `.yarnrc.yml` `npmMinimalAgeGate: 7d` or `14d`.
- Bun: `bunfig.toml` `[install] minimumReleaseAge = 604800` for 7 days or `1209600` for 14 days in seconds. Bun evaluates this gate only at dependency resolution. A version already pinned in `bun.lock` installs under `bun install` and `--frozen-lockfile` without a new age check. Lockfile-diff review remains the control for already-committed versions.
- Deno: `deno.json` `minimumDependencyAge` or CLI `--minimum-dependency-age=P7D` / `P14D` where supported by the pinned Deno version.
- uv: `exclude-newer = "7 days"` or `"14 days"`.
- pip 26.1+: `--uploaded-prior-to=P7D` or `P14D` where the package index provides upload-time metadata.
- Poetry 2.4+: `solver.min-release-age = 7` (days). Poetry ignores a version when any of its distribution files is younger than the gate.

Cooldowns can delay urgent vulnerability fixes. Use the security-fix exception path from `SKILL.md` instead of globally lowering gates.

## JavaScript and TypeScript manager selection

Use this decision order before running any JavaScript/TypeScript package manager:

1. Detect the `packageManager` field, lockfiles, workspace configuration, CI install commands, release automation, and contributor documentation.
2. Preserve the project's exact pinned manager when one is established. Do not introduce a second manager, generate a competing lockfile, or run one manager's scripts against another manager's installed dependency tree.
3. For a new or genuinely unpinned project, prefer pnpm. Pin an exact pnpm version in `package.json`, commit `pnpm-lock.yaml`, and adopt the hardened `pnpm-workspace.yaml` policy below.
4. For an npm-managed project whose user or organization wants pnpm, make migration a separately authorized and reviewed change. If migration is outside scope, keep npm as the compatibility path and report pnpm as a future hardening option.

Reviewed npm-to-pnpm migration checklist:

- Record the current Node and npm versions, package-manager field, workspace layout, registry/auth configuration, scripts, CI/release commands, lockfile status, and any dependency build exceptions.
- Pin the chosen exact pnpm version before use. Run `pnpm import` against the existing lock with lifecycle scripts disabled by project policy, then inspect the resulting resolution and source changes before any build or test.
- Add the hardened `pnpm-workspace.yaml` policy, including the age gate, trust policy, strict dependency-build handling, and committed `allowBuilds` decisions for reviewed exceptions.
- Remove the obsolete lockfile in the same reviewed change; never leave competing lockfiles or ambiguous CI commands.
- Start from a clean dependency tree. Do not run `pnpm run` against `node_modules` produced by npm.
- Perform the first install with `pnpm install --frozen-lockfile --ignore-scripts`. Review ignored or required builds with `pnpm approve-builds`, approve only necessary identities, commit the resulting `allowBuilds` decisions, then repeat the locked install and verify build, test, start, packaging, CI, and release behavior.
- Inspect the final manifest, lockfile, workspace config, CI, docs, and repository diff for unintended dependency, registry, script, or source changes.

## npm

Project `.npmrc`:

```ini
save-exact=true
ignore-scripts=true
fund=false
audit=true
min-release-age=7
allow-git=none
allow-remote=none
```

Use `min-release-age=14` for high-risk runtime, CI/CD, auth, crypto, networking, native-binary, installer, or transitive-heavy dependency surfaces. Confirm the running npm CLI is 11.10.0 or newer before treating `min-release-age` as enforced.

`allow-git` and `allow-remote` control non-registry sources. Values are `none` (block), `root` (direct dependencies only), and `all` (including transitive). npm 11.10+ / 11.15+ introduced the flags. npm 12 defaults both to `none`. Keep them at `none` unless a reviewed direct dependency requires a Git or remote-tarball source. Do not set `all` to make CI pass.

On npm 12+, lifecycle scripts and implicit `node-gyp` rebuilds are opt-in. Review pending scripts, then commit a pinned allowlist:

```sh
npm approve-scripts --allow-scripts-pending
npm approve-scripts <pkg>
npm deny-scripts <pkg>
```

`npm approve-scripts` writes `allowScripts` in `package.json`. Prefer version-pinned approvals. `ignore-scripts=true` still wins over the allowlist. Remove the blanket ignore only after the allowlist is reviewed and committed. Observe skipped-script warnings on npm 11.16+ before the v12 default flip. Never pass `--dangerously-allow-all-scripts` or set `allow-git=all` / `allow-remote=all` to silence those warnings.

Use `npm ci --ignore-scripts` for existing projects. If lifecycle scripts are required, review the exact version, resolved URL, and integrity first, then run the narrowest trusted rebuild command. Run `npm audit signatures` where supported to verify registry signatures and provenance attestations for installed packages.

## pnpm

Project `pnpm-workspace.yaml`:

```yaml
minimumReleaseAge: 10080
minimumReleaseAgeIgnoreMissingTime: false
minimumReleaseAgeStrict: true
trustPolicy: no-downgrade
blockExoticSubdeps: true
strictDepBuilds: true
verifyDepsBeforeRun: error
savePrefix: ""
```

For high-risk repos:

```yaml
minimumReleaseAge: 20160
```

Use:

```sh
pnpm install --frozen-lockfile --ignore-scripts
pnpm approve-builds
```

Review lifecycle/build scripts with `pnpm approve-builds` and commit reviewed `allowBuilds` decisions in `pnpm-workspace.yaml`. Do not enable `dangerouslyAllowAllBuilds` for normal projects.

Review `pnpm-workspace.yaml`, `.pnpmfile.cjs`, `patches/`, overrides, catalog entries, exotic sources, and registry aliases.

## Yarn Berry

Project `.yarnrc.yml`:

```yaml
enableImmutableInstalls: true
enableScripts: false
enableHardenedMode: true
checksumBehavior: throw
defaultSemverRangePrefix: ""
npmMinimalAgeGate: 7d
npmPreapprovedPackages: []
approvedGitRepositories: []
npmPublishProvenance: true
```

Use `npmMinimalAgeGate: 14d` for high-risk dependency surfaces. Use `YARN_ENABLE_SCRIPTS=0 yarn install --immutable --immutable-cache --check-cache`. `--mode=skip-build` is a one-shot alternative that skips the build step. Berry has no `--ignore-scripts`; a freshly cloned repo will not have `enableScripts: false` unless you set the env var or flag. Use hardened mode especially for pull requests that modify manifests or lockfiles. Review `dependenciesMeta` script approvals, `packageExtensions`, `patch:` dependencies, plugins, `.pnp.cjs`, and approved Git repositories.

## Bun

Project or user `bunfig.toml`:

```toml
[install]
frozenLockfile = true
minimumReleaseAge = 604800
```

For high-risk repos, use `1209600`. Prefer:

```sh
bun install --frozen-lockfile --ignore-scripts
```

Keep `bun.lock` or `bun.lockb` committed when the project uses Bun. Review `trustedDependencies` before allowing dependency lifecycle scripts. Bun's script behavior has changed over time; verify behavior against the pinned Bun version in use and avoid relying on unreviewed automatic script execution.

## Deno and JSR

Prefer exact versions, checked-in `deno.lock`, and frozen lockfile configuration:

```json
{
  "lock": {
    "path": "./deno.lock",
    "frozen": true
  },
  "minimumDependencyAge": "P7D"
}
```

For high-risk repos, use `"P14D"`. Deno blocks npm lifecycle scripts by default; review and persist exceptions with:

```sh
deno approve-scripts
```

Treat `deno x` / `dx` as equivalent to `npx`: it runs npm or JSR package binaries and can request broad permissions. Review permission flags such as `--allow-env`, `--allow-read`, `--allow-write`, `--allow-net`, `--allow-run`, and `--allow-all`.

## pip

For unreviewed trees, require wheels and hashes. A hashed sdist still runs its build backend:

```sh
python -m pip install --only-binary=:all: --require-hashes --uploaded-prior-to=P7D -r requirements.txt
```

Use `P14D` for high-risk dependency surfaces. `--uploaded-prior-to` only works with package indexes that provide upload-time metadata and should fail closed otherwise. Age-check the selected file's upload time, not only the version's first-release time.

Requirements pattern:

```text
package-name==1.2.3 \
    --hash=sha256:<hash>
```

Avoid `--trusted-host`, broad `--extra-index-url`, and unpinned VCS requirements unless the project has a reviewed reason.

## uv

Use locked syncs:

```sh
uv sync --locked
uv sync --frozen
```

Project `uv.toml` or `pyproject.toml` policy:

```toml
exclude-newer = "7 days"
```

For high-risk repos:

```toml
exclude-newer = "14 days"
```

Use `exclude-newer-package` only for documented security-fix exceptions. For private indexes, prefer explicit package-to-index mappings and avoid dependency-confusion fallbacks:

```toml
[[tool.uv.index]]
name = "internal"
url = "https://packages.example.com/simple"
explicit = true
```

Use exact pins for high-risk additions and review `uv.lock` diffs before execution.

## Poetry

For unreviewed trees, require wheels so a hashed sdist cannot run a build backend:

```sh
POETRY_INSTALLER_ONLY_BINARY=:all: poetry sync
```

`installer.only-binary` needs Poetry 2.0+. Avoid `poetry update` unless intentionally updating. Review dependency groups and source repositories in `pyproject.toml`. On Poetry 2.4+, `solver.min-release-age` ignores a version when any of its files is younger than the gate.

## Pipenv

For unreviewed trees:

```sh
PIP_ONLY_BINARY=:all: pipenv sync
```

Prefer `pipenv sync` over `pipenv install` for existing locks. Hashes alone do not prevent sdist build-backend execution.

## Cargo

Use locked builds:

```sh
cargo build --locked
cargo test --locked
cargo fetch --locked
```

Review `build.rs`, proc macros, feature flags, native links, `cargo install`, and `.cargo/config.toml`. Use `cargo vet`, `cargo audit`, or project-standard review tooling where already adopted.

## Go

Use:

```sh
go mod verify
go test ./...
```

Avoid disabling checksum verification for public modules. Review `replace` directives, private module settings, `GONOSUMDB`, `GONOPROXY`, and `GOPRIVATE`.

## Gradle

Prefer dependency locking and verification metadata by default for application builds:

```sh
./gradlew dependencies --write-locks
./gradlew --write-verification-metadata sha256 help
```

`./gradlew --write-locks` with no task resolves no configuration, writes no `gradle.lockfile`, and exits 0. In a multi-project build, run `./gradlew :subproject:dependencies --write-locks` for each subproject that must be locked. Only run these update commands when intentionally changing baseline metadata. Review dynamic versions, plugin repositories, wrapper changes, init scripts, and custom repository additions.

## Maven

Maven does not have a first-party lockfile model equivalent to pnpm, uv, Cargo, NuGet, or Gradle. Prefer:

- pinned plugin and dependency versions
- repository manager governance and checksum fail-closed policy
- Maven Enforcer rules such as `banDynamicVersions`
- bans on `LATEST`, `RELEASE`, ranges, snapshots in release builds, and unapproved repositories
- Maven wrapper checksums where the project uses the wrapper

Treat Maven plugins as executable code.

## .NET

Prefer locked restore:

```sh
dotnet restore --locked-mode
```

Use `packages.lock.json`, central package management, and trusted package sources. Add Package Source Mapping when multiple feeds are configured to reduce dependency-confusion risk. Review `NuGet.config` for unexpected feeds and credentials.

## Composer and PHP

Use first-pass installs without scripts/plugins:

```sh
composer install --no-scripts --no-plugins
composer audit
```

Use Composer's modern `config.policy` / security blocking controls where available so insecure versions are blocked during update/require/delete operations. Review Composer plugins, scripts, repositories, path repositories, branch aliases, `source.reference`, `dist.reference`, and autoload changes before enabling scripts/plugins or loading `vendor/autoload.php`. `--no-scripts --no-plugins` does not prevent later execution through eager autoloaded files or framework bootstrap.

## Bundler and Ruby

Prefer persistent locked/deployment settings instead of deprecated transient flags:

```sh
bundle config set --local deployment true
bundle config set --local frozen true
bundle install
```

Avoid `bundle update` unless intentionally updating. Review native extensions, gem sources, and plugin behavior.

## Containers

Prefer digest-pinned base images:

```Dockerfile
FROM registry.example.com/image@sha256:<digest>
```

Avoid `latest`, unverified install scripts, broad package upgrades, and adding package repositories without key and source review.
