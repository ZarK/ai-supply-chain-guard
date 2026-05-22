# npm Trusted Publishing

Use this reference when a task adds, reviews, debugs, or changes npm Trusted Publishing, npm staged publishing, npm package identity, or GitHub OIDC release workflows.

npm Trusted Publishing is an identity and provenance mechanism. It does not prove the package contents are safe, and small identity mismatches can produce misleading authentication errors.

Primary references:

- [npm Trusted Publishing](https://docs.npmjs.com/trusted-publishers/)
- [npm staged publishing](https://docs.npmjs.com/cli/v11/commands/npm-stage/)

## Exact-match checklist

Before changing workflow authentication, compare the npm trusted-publisher configuration against the GitHub OIDC claims and package metadata exactly:

- npm package name, including scope and casing.
- GitHub owner or organization, with exact casing.
- GitHub repository name, with exact spelling and casing.
- Workflow filename, including `.yml` or `.yaml`.
- GitHub environment name, if the trusted publisher requires one.
- Allowed action: `npm publish`, `npm stage publish`, or both.
- `package.json` `repository.url`, which npm requires to match the GitHub repository.
- Package rename or repository rename mismatches, including visually similar names.

Treat npm errors such as `OIDC token exchange error - package not found` as possible trusted-publisher identity mismatches, not only as evidence that the registry package is absent.

## Stage-only publishing flow

Prefer stage-only CI publishing when npm staged publishing fits the project:

1. Configure the npm trusted publisher to allow `npm stage publish`.
2. Avoid allowing direct `npm publish` from CI unless the maintainer explicitly needs fully automatic publishing.
3. Keep `id-token: write` scoped to the publish job and avoid package-manager caches in the publish job unless there is a documented reason.
4. Stage from CI with `npm stage publish`.
5. Require a human maintainer to approve or reject the staged package in npm with proof-of-presence.
6. Require package 2FA and remove or avoid legacy publish tokens after trusted publishing is configured.

`npm stage publish` uses OIDC and does not require 2FA at publish time; `npm stage approve` and `npm stage reject` require proof-of-presence. Treat `npm stage list`, `npm stage view`, `npm stage download`, `npm stage approve`, and `npm stage reject` as stage-management commands, not as substitutes for OIDC publishing.

Do not treat a GitHub environment approval and an npm staged-package approval as the same gate. A GitHub environment can be useful for claim matching or deployment policy, while npm staged approval controls whether npm releases the already staged package.

## New package bootstrap

Trusted Publishing is configured for an existing package. For a brand-new npm package name:

1. Check whether the package exists with `npm view <pkg> name version dist-tags repository --json`.
2. If it does not exist, explain that a one-time bootstrap publish may be needed before trusted publishing can be configured.
3. Bootstrap with the narrowest manual publish path, account 2FA, and no long-lived automation token unless explicitly required.
4. Configure Trusted Publishing immediately after the bootstrap publish.
5. For renamed packages, reject stale staged versions under the old package name and verify docs, imports, package metadata, lockfiles, and workflow comments all use the intended name.

## Tool and workflow pinning

Distinguish documentation-only capability floors from executable pins:

- Record npm and Node.js minimum support requirements from npm's current docs as prerequisites, not as floating executable commands.
- Do not put floating `>=` versions in release workflow commands.
- If a workflow must install a newer npm CLI, pin an exact npm package version and apply the normal dependency intake: exact version, release age, source, scripts disabled where practical, and lock or integrity review where practical.
- Avoid bespoke `curl` plus manual hash scripts as the default way to pin npm CLI tooling.
- Pin GitHub Actions and reusable workflows to full-length commit SHAs, with a same-line reviewed version comment for human readability.

## Secret-safe diagnostics

Default to primary docs, exact config comparison, and normal CI logs before adding custom release-auth diagnostics.

Do not log:

- OIDC JWTs or decoded full JWT payloads.
- Auth headers or registry exchange responses that may contain credentials.
- `NODE_AUTH_TOKEN`, `NPM_TOKEN`, `ACTIONS_ID_TOKEN_REQUEST_TOKEN`, or equivalent variables.
- Full environment dumps in publish jobs.
- `set -x` around auth, publish, or token exchange steps.
- npm verbose or debug logs unless reviewed for secret exposure first.
- Token-presence checks that make logs look like token handling is happening.

If temporary diagnostics are unavoidable, keep them narrow and non-secret: package name, workflow filename, repository claim string, environment name, ref, event type, command being staged, and registry error code. Remove temporary diagnostics before the final workflow run.

## Troubleshooting tree

For npm Trusted Publishing or staged publishing failures, check in this order:

1. Confirm the package exists when configuring Trusted Publishing.
2. Confirm the exact package being published or staged matches the trusted-publisher package.
3. Compare npm trusted-publisher fields against GitHub owner, repository, workflow filename, and environment exactly.
4. Confirm the allowed action includes `npm stage publish` for staged flows or `npm publish` for direct flows.
5. Confirm the publish job, and any reusable workflow that participates in OIDC, has `permissions: id-token: write`.
6. Confirm the supported runner and workflow event behavior from npm's current docs. Do not assume self-hosted runner support. For `workflow_dispatch`, npm validates the workflow that defines the trigger; for `workflow_call`, npm validates the caller workflow.
7. Confirm no publish token, private install token, or package-manager auth token is being confused with OIDC publishing.
8. Confirm `package.json` `repository.url` points at the GitHub repository expected by npm.
9. Only after identity, permissions, runner, event, and package metadata checks pass should the workflow structure or temporary non-secret diagnostics change.

Common misleading symptoms include:

- `ENEEDAUTH`
- `E401 Unable to authenticate, your authentication token seems to be invalid`
- `OIDC token exchange error - package not found`
- `npm whoami` not reflecting OIDC publish authorization
