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

## Releases

Released versions are Git tags. Do not add a `version` field to `supply-chain-guard/SKILL.md`.

To cut a release after the release commit is on `main`:

```sh
git switch main
git pull --ff-only origin main
git tag -s v1.0.0 -m "v1.0.0"
git push origin v1.0.0
```

The release workflow validates the tag, packages `supply-chain-guard/`, writes a SHA-256 checksum, and creates a GitHub release.

See agentskills.io for more on the skill format.
