# AI Supply Chain Guard

Agent-facing install guide for a portable, tool-agnostic supply-chain defense skill.

If a human gave you this repository URL and said something like "install this skill URL", install the `supply-chain-guard/` folder from this repo. Do not run package-manager installs, setup scripts, generators, or one-line installers from this repository. The installable unit is plain Markdown: `supply-chain-guard/SKILL.md` plus optional reference files under `supply-chain-guard/references/`.

Repository URL:

```text
https://github.com/ZarK/ai-supply-chain-guard
```

## Agent Install Contract

You are installing a local agent skill, not a software package.

1. Fetch the repository into a temporary directory.
2. Verify that `supply-chain-guard/SKILL.md` exists.
3. Copy the full `supply-chain-guard/` directory into the user's agent skill location.
4. If the target tool does not have native skills, add a small bridge instruction that points at the installed skill.
5. Verify by reading the installed `SKILL.md`.
6. Start using the skill before dependency, package-manager, CI, release, IDE-extension, MCP, or AI-agent-tool work.

Do not duplicate the full skill into multiple instruction files. Keep one canonical copy of the skill and use bridges that point to it.

## Quick Install For Agents

Use this flow when the user did not name a specific tool.

```sh
repo_tmp="$(mktemp -d)"
git clone --depth 1 https://github.com/ZarK/ai-supply-chain-guard.git "$repo_tmp/ai-supply-chain-guard"
test -f "$repo_tmp/ai-supply-chain-guard/supply-chain-guard/SKILL.md"
```

Preferred project-local install:

```sh
mkdir -p .agents/skills
rm -rf .agents/skills/supply-chain-guard
cp -R "$repo_tmp/ai-supply-chain-guard/supply-chain-guard" .agents/skills/supply-chain-guard
test -f .agents/skills/supply-chain-guard/SKILL.md
```

Portable global install:

```sh
skills_dir="${AGENT_SKILLS_DIR:-$HOME/.agents/skills}"
mkdir -p "$skills_dir"
rm -rf "$skills_dir/supply-chain-guard"
cp -R "$repo_tmp/ai-supply-chain-guard/supply-chain-guard" "$skills_dir/supply-chain-guard"
test -f "$skills_dir/supply-chain-guard/SKILL.md"
```

If your agent has a native skills directory, use that directory instead of `.agents/skills`, but preserve this layout:

```text
<skills-root>/
`-- supply-chain-guard/
    |-- SKILL.md
    `-- references/
```

## Bridge Instruction

For tools that read repository instructions such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, Cursor rules, Windsurf rules, or similar files, add this bridge:

```md
# Supply Chain Guard

Before any install, update, scaffold, package-manager command, CI action/workflow change, IDE/MCP/agent-tool change, release job, or dependency-provided tool execution, read and follow `.agents/skills/supply-chain-guard/SKILL.md`.

For deeper guidance, load only the relevant file from `.agents/skills/supply-chain-guard/references/`.
```

For a global-only install, adapt the path in the bridge to the global skill location, for example `~/.agents/skills/supply-chain-guard/SKILL.md`.

## What This Skill Is

AI Supply Chain Guard is an agent skill that makes coding agents and human reviewers defensive around dependencies and developer tooling. It is meant to reduce preventable exposure to package compromise, CI compromise, malicious install scripts, dependency confusion, unsafe generators, poisoned caches, compromised actions, suspicious IDE extensions, risky MCP servers, and AI-agent tool persistence.

The skill tells an agent to:

- prefer no new dependency when existing code is enough
- pin exact versions and preserve lockfiles
- block or review young package releases before adoption
- disable lifecycle scripts by default
- treat package-manager commands and project generators as code execution
- verify signatures, provenance, attestations, repositories, workflows, refs, builders, and artifact digests where supported
- remember that valid provenance proves origin or integrity, not that code is safe
- treat CI actions, reusable workflows, caches, artifacts, release jobs, IDE extensions, MCP servers, and agent tools as dependencies
- isolate risky installs from valuable credentials
- stop for human approval on ambiguous or high-risk supply-chain actions
- guide incident response when malicious code may have executed

## When To Invoke It

Use the skill before touching any of these:

- package manifests, dependency files, lockfiles, or package-manager config
- `npm`, `npx`, `pnpm`, `yarn`, `bun`, `deno`, `uv`, `pip`, `poetry`, `pipenv`, `cargo`, `go`, `mvn`, `gradle`, `dotnet`, `bundle`, `composer`, `pod`, package installers, or project generators
- GitHub Actions, reusable workflows, workflow templates, CI caches, artifacts, release jobs, or publish pipelines
- Dockerfiles, container image references, binary downloads, one-line shell installers, or generated toolchains
- VS Code/Open VSX/Cursor/Windsurf/JetBrains extensions, MCP configs, AI-agent tools, or automation permissions
- active advisories, suspicious dependency changes, unexpected scripts, new transitive sources, or suspected credential exposure

## Compatibility Pattern

The installable skill follows the common agent skill structure:

```text
supply-chain-guard/
|-- SKILL.md
`-- references/
    |-- attack-patterns.md
    |-- ci-and-repository-hardening.md
    |-- ecosystem-playbooks.md
    |-- incident-response.md
    |-- package-manager-configs.md
    |-- threat-model-and-rules.md
    `-- tooling.md
```

Compatibility choices:

- `SKILL.md` is the only required entrypoint.
- YAML frontmatter contains `name` and `description`.
- Deep detail is in one-level `references/` files so agents load only what they need.
- There are no hidden installers, binaries, package manifests, or tool-specific runtime dependencies.
- The root README is for installation and orientation; the skill itself is the `supply-chain-guard/` directory.

## Install In 30 Agentic Coding Tools

Tool behavior changes quickly. Prefer the tool's current documentation when it differs from this table. The safest portable pattern is always the same: install `supply-chain-guard/` intact, then add a bridge instruction that points at the installed `SKILL.md`.

| Tool | Best install target | Agent setup instruction |
| --- | --- | --- |
| Devin | `.agents/skills/supply-chain-guard/SKILL.md` | Commit the portable skill folder. Ask Devin to use `supply-chain-guard` before dependency, package-manager, CI, release, IDE-extension, MCP, or agent-tool work. |
| Claude Code | `.claude/skills/supply-chain-guard/SKILL.md` or `~/.claude/skills/supply-chain-guard/SKILL.md` | Copy the skill folder to Claude Code's skills directory. Add a `CLAUDE.md` bridge if the project also needs repository-level activation. |
| OpenAI Codex / Codex CLI | `.agents/skills/supply-chain-guard/` plus `AGENTS.md` | Commit the portable install and bridge. For global use, copy the skill folder into the user's global skills directory if the client supports skills. |
| GitHub Copilot Coding Agent / Copilot Chat | `AGENTS.md` and `.github/copilot-instructions.md` | Commit the skill folder and add bridge text to repository instructions. |
| VS Code Copilot Agent Mode | `AGENTS.md` or `.github/instructions/*.instructions.md` | Add a bridge that applies to manifests, lockfiles, workflows, Dockerfiles, release scripts, and agent/MCP config. |
| Cursor | `.cursor/rules/supply-chain-guard.mdc` and/or `AGENTS.md` | Add a Cursor rule that points to `.agents/skills/supply-chain-guard/SKILL.md`. Use always-on activation when available. |
| Windsurf Cascade | `.windsurf/rules/supply-chain-guard.md` and/or `AGENTS.md` | Add a workspace rule with the bridge text. Keep `AGENTS.md` for shared repository context. |
| Sourcegraph Amp | `AGENTS.md` | Commit the bridge and keep the full skill under `.agents/skills/supply-chain-guard/`. |
| Google Gemini CLI | `GEMINI.md` and/or `AGENTS.md` | Add the bridge to `GEMINI.md`. Keep the portable skill in `.agents/skills/`. |
| Google Jules | `AGENTS.md` | Jules-compatible setup is the portable `AGENTS.md` bridge plus the skill folder. |
| Replit Agent | `.agents/skills/supply-chain-guard/SKILL.md`, `replit.md`, or `custom_instruction/instructions.md` | Include the skill folder in project templates. Add the bridge to project or organization instructions. |
| JetBrains Junie | `.junie/AGENTS.md` or configured guidelines path | Add the bridge to Junie guidelines and keep the full skill in `.agents/skills/`. |
| Amazon Q Developer CLI | Custom agent instructions or project prompt | Create a custom Q CLI agent or project instruction that points at the installed skill folder. |
| Factory Droid | `.factory/skills/supply-chain-guard/SKILL.md`, `AGENTS.md`, or `.factory/droids/*.md` | Copy the skill folder to Factory skills when supported, and keep a portable bridge for shared repo context. |
| OpenCode | `AGENTS.md` or `opencode.json` instructions | Commit the bridge in `AGENTS.md`; if explicit config is used, add the same bridge to `opencode.json` instructions. |
| OpenHands | `.openhands/microagents/supply-chain-guard.md` | Add a repo microagent containing the bridge. Do not put dependency install commands in setup scripts unless they pass this skill's review. |
| Aider | `CONVENTIONS.md` or configured read files | Add the bridge to `CONVENTIONS.md` or configure Aider to read a small file that points at `SKILL.md`. |
| Cline | `.clinerules/supply-chain-guard.md` | Add a Cline rule with the bridge and keep the full skill in `.agents/skills/`. |
| Roo Code | `.roo/rules/supply-chain-guard.md` | Add a Roo rule with the bridge. If Roo reads `AGENTS.md`, keep the portable bridge there too. |
| Kilo Code | `.kilocode/rules/supply-chain-guard.md` and/or `AGENTS.md` | Add a Kilo rule with the bridge and keep the portable skill folder in the repository. |
| Continue | `.continue/rules/supply-chain-guard.md` | Add a Continue rule that points to `.agents/skills/supply-chain-guard/SKILL.md`. |
| Qodo Gen | Chat preferences custom instructions or `agents/*.toml` | Add the bridge under custom instructions, or create a custom agent/workflow TOML whose instructions point at the skill. |
| Tabnine Agent | Custom command or chat custom instructions | Create a custom command such as `/supply-chain-guard` containing the bridge, or paste the bridge into custom instructions if available. |
| Warp Agent Mode | `AGENTS.md` or Warp Drive Agent Prompt | Commit the portable bridge in `AGENTS.md`; optionally save the same bridge as a reusable Warp Agent Prompt. |
| Zed Agent / ACP agents | `AGENTS.md` | Use the portable bridge in `AGENTS.md`; this also works when Zed drives compatible external coding agents. |
| Goose | `.agents/skills/supply-chain-guard/SKILL.md`, `~/.agents/skills/supply-chain-guard/SKILL.md`, `AGENTS.md`, or `.goosehints` | Goose supports portable skills. Use project install for repos and global install for user-wide protection. |
| SWE-agent | Task prompt or harness-level instruction file | Include the bridge in the task prompt or harness instructions and mount the skill folder into the workspace. |
| Augment Code | Rules or guidelines | Add a rule/guideline with the bridge and keep the full skill in `.agents/skills/`. |
| Trae | Project rules or `.trae/skills/supply-chain-guard/` if available | Prefer a project rule pointing at `.agents/skills/supply-chain-guard/SKILL.md`. If the client supports skills, copy the folder to its skills directory. |
| Mistral Vibe | `.vibe/skills/supply-chain-guard/SKILL.md`, `~/.vibe/skills/supply-chain-guard/SKILL.md`, or `AGENTS.md` | Copy the skill folder to Vibe's project or global skills directory and keep a portable bridge for repository context. |

## First Use After Install

After installing, read the installed skill and apply it to the current repository:

```text
Use the supply-chain-guard skill before dependency, package-manager, CI, release, IDE-extension, MCP, or AI-agent-tool work in this repo. First inspect the manifests, lockfiles, workflows, package-manager config, and agent/tooling config. Then report what protections are missing before making changes.
```

For humans, the shortest instruction to give your agent is:

```text
Install this skill and use it before dependency or CI work: https://github.com/ZarK/ai-supply-chain-guard
```

## What The Skill Teaches

For the deeper tutorial, read [`supply-chain-guard/references/threat-model-and-rules.md`](supply-chain-guard/references/threat-model-and-rules.md). It explains why the rules exist, including:

- legitimate package releases that briefly ship malicious versions
- install-time scripts, source builds, generators, and one-shot CLIs as code execution
- package-age gates and cooldown exceptions for urgent security fixes
- provenance, trusted publishing, signatures, and attestations as identity/integrity signals rather than malware verdicts
- GitHub Actions, reusable workflows, cache scopes, artifacts, tags, and release jobs as supply-chain dependencies
- `pull_request_target`, poisoned caches, mutable action tags, and overbroad OIDC permissions
- trust downgrade, exotic sources, Git dependencies, tarballs, and registry confusion
- IDE extensions, MCP servers, AI-agent config, and editor marketplaces as executable supply-chain surfaces
- incident response when a malicious dependency may have exposed workstation, CI, SCM, registry, or cloud credentials

## Recommended Companion Controls

This skill changes agent behavior. It should be paired with real controls where the user's environment supports them:

- install-time malware blocking, registry proxying, or package intelligence on developer machines and CI runners
- exact versions, frozen installs, checked-in lockfiles, and lifecycle scripts disabled by default
- native package-age gates such as npm `min-release-age`, pnpm `minimumReleaseAge`, Yarn `npmMinimalAgeGate`, Bun `minimumReleaseAge`, Deno `minimumDependencyAge`, uv `exclude-newer`, and pip `--uploaded-prior-to`
- dependency review, vulnerability alerts, code scanning, secret scanning with push protection, signed commits, and repository rulesets
- trusted publishing, short-lived OIDC credentials, protected release environments, and artifact/provenance verification
- isolated dev containers, VMs, Codespaces, or short-lived runners for risky dependency work

Use third-party products only when they fit the user's environment, budget, and trust model. This skill is not tied to any vendor.

## Sources And References

- [Agent Skills: Overview and specification](https://agentskills.io/)
- [AGENTS.md: Open format for guiding coding agents](https://agents.md/)
- [Devin Docs: Skills](https://docs.devin.ai/product-guides/skills)
- [Claude Code Docs: Skills](https://docs.claude.com/en/docs/claude-code/skills)
- [Goose Docs: Using skills](https://goose-docs.ai/docs/guides/context-engineering/using-skills/)
- [GitHub Docs: Repository custom instructions for Copilot](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions)
- [Cursor Docs: Rules](https://docs.cursor.com/en/context)
- [Windsurf Docs: Rules and AGENTS.md](https://docs.windsurf.com/windsurf/cascade/memories)
- [Gemini CLI Docs: GEMINI.md context files](https://google-gemini.github.io/gemini-cli/docs/cli/gemini-md.html)
- [Replit Docs: custom templates and skills](https://docs.replit.com/teams/custom-templates)
- [JetBrains Docs: Junie guidelines](https://www.jetbrains.com/help/ai-assistant/junie-agent.html)
- [OpenHands Docs: repository microagents](https://docs.openhands.dev/openhands/usage/microagents/microagents-repo)
- [Cline Docs: Cline Rules](https://docs.cline.bot/features/cline-rules/overview)
- [Continue Docs: Rules](https://docs.continue.dev/customize/rules)
- [Kilo Code Docs: rules and AGENTS.md migration](https://kilo.ai/docs/getting-started/migrating)
- [Aider Docs: conventions files](https://aider.chat/docs/usage/conventions.html)
- [Qodo Docs: Agent TOML files](https://docs.qodo.ai/qodo-documentation/qodo-gen/agent/agent-toml-file)
- [Tabnine Docs: Custom commands](https://docs.tabnine.com/main/getting-started/tabnine-cli/features/commands)
- [Sourcegraph Amp Manual: AGENTS.md](https://ampcode.com/manual)
- [Factory Docs: Skills](https://docs.factory.ai/cli/configuration/skills)
- [Factory Docs: AGENTS.md](https://docs.factory.ai/cli/configuration/agents-md)
- [Mistral Docs: Vibe Agents and Skills](https://docs.mistral.ai/mistral-vibe/agents-skills)
- [Google Jules Docs: AGENTS.md support](https://jules.google/docs/changelog/2025-06-20/)
- [Augment Docs: Rules and Guidelines](https://docs.augmentcode.com/setup-augment/guidelines)
- [Zed Docs: Agent Panel](https://zed.dev/docs/ai/agent-panel)
- [Warp Docs: Agent Mode](https://docs.warp.dev/agents/warp-ai/agent-mode)
- [Aikido: Mini Shai-Hulud is back, TanStack and other packages compromised](https://www.aikido.dev/blog/mini-shai-hulud-is-back-tanstack-compromised)
- [Socket: TanStack npm packages compromised in Mini Shai-Hulud attack](https://socket.dev/blog/tanstack-npm-packages-compromised-mini-shai-hulud-supply-chain-attack)
- [TanStack: npm supply-chain compromise postmortem](https://tanstack.com/blog/npm-supply-chain-compromise-postmortem)
- [GitHub Well-Architected: Defending against dependency supply chain attacks](https://wellarchitected.github.com/library/application-security/recommendations/managing-dependency-threats/)
- [GitHub Docs: About supply chain security](https://docs.github.com/en/code-security/concepts/supply-chain-security/about-supply-chain-security)
- [GitHub Docs: About dependency review](https://docs.github.com/en/code-security/concepts/supply-chain-security/about-dependency-review)
- [GitHub Docs: Secure use reference for GitHub Actions](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub Docs: Artifact attestations](https://docs.github.com/actions/concepts/security/artifact-attestations)
- [NIST SSDF SP 800-218 v1.1](https://csrc.nist.gov/pubs/sp/800/218/final)
- [npm Docs: Config](https://docs.npmjs.com/cli/v11/using-npm/config)
- [npm Docs: Trusted publishing](https://docs.npmjs.com/trusted-publishers/)
- [pnpm Docs: Settings](https://pnpm.io/settings)
- [Yarn Docs: Security](https://yarnpkg.com/features/security)
- [Bun Docs: bun install](https://bun.com/docs/cli/install)
- [Deno Docs: approve-scripts](https://docs.deno.com/runtime/reference/cli/approve_scripts/)
- [uv Docs: Settings](https://docs.astral.sh/uv/reference/settings/)
- [pip Docs: pip install](https://pip.pypa.io/en/stable/cli/pip_install/)
- [PyPI Docs: Trusted Publishers](https://docs.pypi.org/trusted-publishers/)
- [OSV-Scanner](https://github.com/google/osv-scanner)
- [OpenSSF Scorecard](https://github.com/ossf/scorecard)

## Contributing

Keep the installable skill concise and durable. Add ecosystem-specific detail to `supply-chain-guard/references/`. Add incident-specific package lists to issues or advisories, not to `SKILL.md`, because compromised package sets change quickly.
