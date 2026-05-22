# Supply Chain Guard

Before any install, update, scaffold, package-manager command, CI action/workflow change, IDE/MCP/agent-tool change, release job, or dependency-provided tool execution, read and follow `supply-chain-guard/SKILL.md`.

For deeper guidance, load only the relevant file from `supply-chain-guard/references/`.

This repository is itself an Agent Skill package. Keep the installable skill folder portable: `SKILL.md` at the skill root, concise frontmatter, and optional supporting files under `references/`.

## Public Metadata Hygiene

Do not inject agent, model, tool, vendor, provider, or session attribution into public repository metadata or communication.

- Branch names must be neutral topic names. Do not use agent/tool prefixes or provider branding.
- Commit subjects and bodies must describe the change and rationale only. Do not add generated-by, assisted-by, co-authored-by, signed-off-by, session IDs, local paths, transcript references, or vendor/tool attribution unless the maintainer explicitly requires that exact trailer.
- Pull request and issue titles, bodies, comments, labels, milestones, release notes, changelogs, and review replies must be maintainer-centered and free of agent/tool/vendor/provider branding.
- Before creating or updating any public branch, commit, pull request, issue, comment, release, or tag, scan the proposed text for accidental attribution, local context, hidden prompts, or tool-specific process narration.
