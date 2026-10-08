# Contributing

Thank you for your interest in contributing to AI Supply Chain Guard!

## Ways to Contribute

- Improve the skill rules in SKILL.md (keep it concise and durable)
- Expand or update references/ for new ecosystems or best practices
- Improve installation instructions for new AI agents/tools
- Add examples or bridge files
- Report issues with supply chain advice
- Help with documentation, promotion, or testing

## Guidelines

- Fork and PR to main
- Follow the spirit of the skill itself when modifying code or docs
- Discuss major changes in Issues first

## Changelog entries

Every change under `supply-chain-guard/` is user-facing. This is the folder in the release archive.
Add at least one new bullet under `## Unreleased` in [CHANGELOG.md](CHANGELOG.md) for each user-facing change.
Keep each bullet on one line. Describe the change in plain English.

All other paths are infrastructure. These include `.github/`, workflows, scripts, lint and link-check configuration,
`README.md`, `CONTRIBUTING.md`, and `examples/`. Infrastructure-only and changelog-only changes need no entry.

For published findings, use the [security finding template](.github/ISSUE_TEMPLATE/security_finding.md).
Use this exact source format in the issue body:

```markdown
## Sources

- https://example.com/first-write-up
- https://example.com/second-write-up
```

Use the exact heading `## Sources`. End the section at the next `## ` heading or the end of the body.
Each non-empty line must contain `- ` and one bare `https://` URL. Put no other text in the section.

Use this changelog format for a source-tagged issue:

```markdown
- <Summary of the change>. Sources: [<Publisher>](<url>), [<Publisher>](<url>). (#<issue>)
```

Replace the placeholders. Include every source URL as a Markdown link target and the issue reference in one new bullet.
Connect the PR to the issues it closes with closing references, such as `Closes #123` in the PR body.

The `changelog` check runs when a PR opens, changes, reopens, or receives commits.
For user-facing changes, it compares Unreleased bullets with the base branch.
It reads the issues from the PR's closing references. For each source-tagged issue, it checks the format, URLs, and issue reference.
An issue without Sources needs only a normal changelog entry. Infrastructure-only PRs pass without an entry.
There is no opt-out label or fallback format.

Run the offline parser and release-note checks with Git Bash or Bash:

```sh
bash .github/scripts/test-changelog.sh
```

The validator also accepts local files. Use a NUL-separated changed-path file, the base changelog, and the proposed changelog.
Append an issue number and an issue-body file for each closing issue:

```sh
bash .github/scripts/validate-changelog.sh paths.nul base.md head.md 123 issue.md
```

## Releases

Released versions are Git tags. Do not add a `version` field to `supply-chain-guard/SKILL.md`.

Use Bash, Git, `gh`, `jq`, and coreutils. Authenticate `gh` as the maintainer.
Configure Git signing before release preparation.

Start from a clean, current `main`. Run the [preparation script](scripts/prepare-release.sh) with the next SemVer tag:

```sh
git switch main
git pull --ff-only origin main
bash scripts/prepare-release.sh v1.7.0
```

The script refuses a dirty or outdated `main`, an existing tag or release, and an empty Unreleased section.
It moves Unreleased entries under `## vX.Y.Z - YYYY-MM-DD` with the UTC date and leaves an empty `## Unreleased`.
It creates `prepare-vX.Y.Z`, makes a signed `Prepare vX.Y.Z` commit, pushes that branch, and opens a PR.
It does not push to `main` or force-push. If a later step fails, inspect the local branch and open PR before continuing.

Review the release PR. Require the status checks and one approving review.
Merge through the `main` ruleset with signed commits and linear history.
Update local `main`. Sign the tag on the release PR's merge commit, then push the tag:

```sh
git switch main
git pull --ff-only origin main
git log --oneline -5
# Replace <merge-commit> with the release PR's merge commit.
git tag -s v1.7.0 <merge-commit> -m "v1.7.0"
git push origin v1.7.0
```

If that commit is `HEAD`, use `git tag -s v1.7.0 -m "v1.7.0"`.
The release workflow reads the matching version section from `CHANGELOG.md` at the tagged commit.
It fails if the section is missing or empty. It publishes that section as the release notes, followed by the artifact and checksum line.
It packages exactly `supply-chain-guard/` and writes a SHA-256 checksum.

After the changelog workflow merges, add `changelog` to the required status checks in the `main` ruleset.
Keep the existing Markdown lint, review, signature, and linear-history requirements.

See agentskills.io for more on the skill format.
