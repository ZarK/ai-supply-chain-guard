# Package Manager Configs

Use this reference when the user asks for durable project or workstation defaults. Apply changes only when they match the project's workflow and after explaining tradeoffs.

## Native package-age gates

Where supported, enforce the 7-day/14-day age policy in package-manager configuration as well as in agent review:

- npm v11+: `.npmrc` `min-release-age=7` or `min-release-age=14` in days. Do not combine with `before`.
- pnpm v10.16+/v11: `pnpm-workspace.yaml` `minimumReleaseAge: 10080` for 7 days or `20160` for 14 days in minutes.
- Yarn Berry 4.12+: `.yarnrc.yml` `npmMinimalAgeGate: 7d` or `14d`.
- Bun: `bunfig.toml` `[install] minimumReleaseAge = 604800` for 7 days or `1209600` for 14 days in seconds.
- Deno: `deno.json` `minimumDependencyAge` or CLI `--minimum-dependency-age=P7D` / `P14D` where supported by the pinned Deno version.
- uv: `exclude-newer = "7 days"` or `"14 days"`.
- pip 26.1+: `--uploaded-prior-to=P7D` or `P14D` where the package index provides upload-time metadata.

Cooldowns can delay urgent vulnerability fixes. Use the security-fix exception path from `SKILL.md` instead of globally lowering gates.

## npm

Project `.npmrc`:

```ini
save-exact=true
ignore-scripts=true
fund=false
audit=true
min-release-age=7
allow-git=root
```

Use `min-release-age=14` for high-risk runtime, CI/CD, auth, crypto, networking, native-binary, installer, or transitive-heavy dependency surfaces.

Use `npm ci --ignore-scripts` for existing projects. If lifecycle scripts are required, review them first and run the narrowest trusted rebuild command. Run `npm audit signatures` where supported to verify registry signatures and provenance attestations for installed packages.

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

Use `npmMinimalAgeGate: 14d` for high-risk dependency surfaces. Use `yarn install --immutable --immutable-cache --check-cache`; use hardened mode especially for pull requests that modify manifests or lockfiles. Review `dependenciesMeta` script approvals, `packageExtensions`, `patch:` dependencies, plugins, `.pnp.cjs`, and approved Git repositories.

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

Prefer hashed requirements for deployed applications:

```sh
python -m pip install --require-hashes --uploaded-prior-to=P7D -r requirements.txt
```

Use `P14D` for high-risk dependency surfaces. `--uploaded-prior-to` only works with package indexes that provide upload-time metadata and should fail closed otherwise.

When feasible for high-risk installs, prefer wheels over source builds:

```sh
python -m pip install --only-binary=:all: --require-hashes --uploaded-prior-to=P7D -r requirements.txt
```

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

Use:

```sh
poetry sync
```

Avoid `poetry update` unless intentionally updating. Review dependency groups and source repositories in `pyproject.toml`.

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
./gradlew --write-locks
./gradlew --write-verification-metadata sha256 help
```

Only run these update commands when intentionally changing baseline metadata. Review dynamic versions, plugin repositories, wrapper changes, init scripts, and custom repository additions.

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

Use Composer's modern `config.policy` / security blocking controls where available so insecure versions are blocked during update/require/delete operations. Review Composer plugins, scripts, repositories, path repositories, and autoload changes before enabling scripts/plugins.

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
