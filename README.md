# AI Supply Chain Guard

An installable, tool-agnostic agent skill that makes AI coding agents and human reviewers defensive around dependencies, package managers, project generators, and installer scripts.

The skill is designed for current and future supply-chain attacks, not just one advisory list. It tells an agent to pin versions, respect lockfiles, block young package releases, disable lifecycle scripts by default, verify package identity and provenance, isolate risky installs, and stop for explicit approval when it cannot verify safety.

## Why this exists

Recent npm campaigns such as Mini Shai-Hulud show the pattern this skill is meant to resist: compromised packages and trusted publishing paths used to steal GitHub, npm, cloud, Kubernetes, and Vault credentials from developer machines and CI runners, then propagate through package releases.

This skill turns those lessons into agent behavior:

- prefer no new dependency when existing code is enough
- avoid `latest`, floating ranges, mutable Git branches, and unverified tarballs
- require package-age delays before new versions are installed
- install with lifecycle scripts disabled unless reviewed
- keep lockfiles authoritative
- compare manifests and lockfiles against live advisories during incidents
- recommend workstation, CI, and repository hardening such as install-time malware blocking, dependency review, code scanning, secret scanning, signed commits, rulesets, and trusted publishing
- escalate to humans for credential rotation, destructive cleanup, publishing changes, or ambiguous high-risk installs

## Repository layout

```text
.
|-- README.md
|-- prompt.md
`-- supply-chain-guard/
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

`supply-chain-guard/SKILL.md` is the portable skill entrypoint. The `references/` files are loaded by agents or read by humans only when deeper detail is needed. The root README and prompt are for humans.

## What it covers

- dependency additions, upgrades, and lockfile changes
- package-manager installs and syncs
- project generators and one-shot CLIs
- CI actions, reusable workflows, release jobs, caches, and artifacts
- IDE extensions, MCP servers, and AI-agent tool configs
- suspicious package and active incident review
- CI, release, and repository hardening
- secure package-manager defaults
- optional scanning and install-time guard tools

## What it cannot guarantee

No skill can prove every dependency is safe. Signatures, provenance, trusted publishing, and attestations prove identity or integrity properties; they do not prove the built code is benign. This skill reduces preventable risk by forcing slower, explicit, evidence-based dependency decisions. It should be paired with real controls: isolated environments, registry intelligence, secret scanning, dependency review, code review, provenance verification, least-privilege CI, and incident response.

## Learn the threat model

Start with [`supply-chain-guard/references/threat-model-and-rules.md`](supply-chain-guard/references/threat-model-and-rules.md) if you want the "why" behind the skill. It teaches the recent attack patterns this skill is designed around:

- legitimate packages that briefly publish malicious versions
- install-time lifecycle scripts and source builds as code execution
- trusted publishing and provenance as identity evidence, not safety proof
- GitHub Actions, reusable workflows, caches, and artifacts as supply-chain dependencies
- package-age gates, lockfiles, and exact pins as practical blast-radius reducers
- IDE extensions, MCP servers, and AI-agent tool configs as executable development dependencies
- incident response when a malicious install may have exposed credentials or release infrastructure

That tutorial is meant for humans and agents. The shorter `SKILL.md` stays focused on what to do; the tutorial explains why those rules exist.

## Install globally

Clone the repo and copy the skill folder into your agent's global skills directory.

```sh
git clone https://github.com/YOUR-ORG/ai-supply-chain-guard.git
mkdir -p "$AGENT_SKILLS_DIR"
cp -R ai-supply-chain-guard/supply-chain-guard "$AGENT_SKILLS_DIR/"
```

Set `AGENT_SKILLS_DIR` to the global skills directory used by your agent or client. The only required file is `SKILL.md`.

## Install in one project

Copy the skill folder into the project's skills location if your agent supports project-local skills:

```sh
mkdir -p .agents/skills
cp -R /path/to/ai-supply-chain-guard/supply-chain-guard .agents/skills/
```

If your agent uses a different directory name, keep the folder intact and adapt only the destination path.

## Agent skill compatibility

The installable unit is the `supply-chain-guard/` directory. It follows the common Agent Skills shape used by modern coding agents:

- one named folder per skill
- required `SKILL.md` at the skill root
- YAML frontmatter with a short `name` and task-triggering `description`
- concise primary instructions in `SKILL.md`
- optional supporting files under `references/`, loaded only when needed
- no hidden installer, binary payload, or tool-specific metadata inside the skill folder

For maximum compatibility, install the folder intact at:

```text
.agents/skills/supply-chain-guard/SKILL.md
```

Then add thin bridge files for tools that use `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, Cursor rules, Windsurf rules, or similar instruction systems. The bridge should point to the skill, not duplicate it.

## Install for agentic coding tools

There is not yet one universal skill loader across all coding agents. The most portable setup is:

1. Keep the full skill at `.agents/skills/supply-chain-guard/`.
2. Add a short tool-specific rule or instruction file that tells the agent to read that skill before dependency, CI, package-manager, IDE-extension, MCP, or release-workflow work.
3. Avoid copying the full skill into many tool-specific files. Duplicate policy text will drift.

Portable project install:

```sh
mkdir -p .agents/skills
cp -R /path/to/ai-supply-chain-guard/supply-chain-guard .agents/skills/
```

Portable `AGENTS.md` bridge:

```md
# Supply Chain Guard

Before any install, update, scaffold, package-manager command, CI action/workflow change, IDE/MCP/agent-tool change, or dependency-provided tool execution, read and follow `.agents/skills/supply-chain-guard/SKILL.md`.

For deeper guidance, load only the relevant file from `.agents/skills/supply-chain-guard/references/`.
```

For tools without native skill or rule folders, paste the bridge above into the tool's global custom instructions or include it at the top of the task prompt.

### Tool adapter matrix

This list covers 30 common agentic coding tools and clients as of 2026-05. It is not a ranking, and product behavior changes quickly. Prefer the tool's current docs when they differ from this table.

| Tool | Best current install target | Agent-friendly setup |
| --- | --- | --- |
| Devin | `.agents/skills/supply-chain-guard/SKILL.md` | Native Agent Skills layout. Commit the skill folder and ask Devin to use `supply-chain-guard` for dependency, package-manager, CI, release, IDE-extension, and MCP work. |
| Claude Code | `.claude/skills/supply-chain-guard/SKILL.md` or `~/.claude/skills/supply-chain-guard/SKILL.md` | Copy the skill folder to Claude Code's skills directory. Add one line to `CLAUDE.md`: `Use the supply-chain-guard skill before dependency, package-manager, CI, MCP, IDE-extension, or release work.` |
| OpenAI Codex / Codex CLI | `.agents/skills/supply-chain-guard/` plus `AGENTS.md` | Commit the portable install and bridge. For global use, also copy the skill folder into the user's global skills directory if the client supports skills. |
| GitHub Copilot Coding Agent / Copilot Chat | `AGENTS.md` and `.github/copilot-instructions.md` | Commit the portable bridge in `AGENTS.md`. Also add `.github/copilot-instructions.md` pointing Copilot to `.agents/skills/supply-chain-guard/SKILL.md`. |
| VS Code Copilot Agent Mode | `AGENTS.md` or `.github/instructions/*.instructions.md` | Use the portable bridge in `AGENTS.md`. If you prefer path-specific instructions, create `.github/instructions/supply-chain-guard.instructions.md` and make it apply to manifests, lockfiles, workflow files, Dockerfiles, and agent/MCP config. |
| Cursor | `.cursor/rules/supply-chain-guard.mdc` and/or `AGENTS.md` | Add a Cursor rule that points to `.agents/skills/supply-chain-guard/SKILL.md`. Use `Always` or equivalent activation if available; otherwise describe dependency/CI/package-manager triggers. |
| Windsurf Cascade | `.windsurf/rules/supply-chain-guard.md` and/or `AGENTS.md` | Add a workspace rule with the bridge text. Windsurf also processes `AGENTS.md`, so keep the portable bridge at repo root when you use multiple tools. |
| Sourcegraph Amp | `AGENTS.md` | Amp reads `AGENTS.md` files. Commit the portable bridge and keep the full skill under `.agents/skills/supply-chain-guard/`. |
| Google Gemini CLI | `GEMINI.md` and/or `AGENTS.md` | Add the bridge to `GEMINI.md`; keep the portable install in `.agents/skills/`. If using clients that read `AGENTS.md`, keep both files aligned by pointing them at the same skill folder. |
| Google Jules | `AGENTS.md` | Jules reads repository `AGENTS.md`; commit the portable bridge and skill folder. |
| Replit Agent | `.agents/skills/supply-chain-guard/SKILL.md`, `replit.md`, or `custom_instruction/instructions.md` | Include the skill folder in project or template `.agents/skills/`. Add the bridge to `custom_instruction/instructions.md` for organization templates, or to `replit.md` for one project. |
| JetBrains Junie | `.junie/AGENTS.md` or configured Guidelines path | Add the bridge to `.junie/AGENTS.md`; commit `.agents/skills/supply-chain-guard/`. Older Junie setups may use `.junie/guidelines.md`, but prefer the current AGENTS path when available. |
| Amazon Q Developer CLI | Custom agent instructions or project prompt | Create a custom Q CLI agent whose instructions include the bridge. Keep the skill folder in the repo and reference it from the custom agent. |
| Factory Droid | `.factory/skills/supply-chain-guard/SKILL.md`, `AGENTS.md`, or `.factory/droids/*.md` | Copy the skill folder to `.factory/skills/` when using Factory skills. Also keep the portable `AGENTS.md` bridge for shared repo context. |
| OpenCode | `AGENTS.md` or `opencode.json` instructions | Commit the portable bridge in `AGENTS.md`; if your OpenCode setup uses explicit config, add the same bridge to `opencode.json` instructions. |
| OpenHands | `.openhands/microagents/supply-chain-guard.md` | Add a repo microagent containing the bridge. Do not put install commands in `.openhands/setup.sh` unless the setup command itself has passed this skill's review. |
| Aider | `CONVENTIONS.md` or configured read files | Add the bridge to `CONVENTIONS.md` or configure Aider to read a small `supply-chain-guard.md` file that points at `.agents/skills/supply-chain-guard/SKILL.md`. |
| Cline | `.clinerules/supply-chain-guard.md` | Add a Cline rule with the bridge. Keep the full skill in `.agents/skills/`. |
| Roo Code | `.roo/rules/supply-chain-guard.md` | Add a Roo rule with the bridge. If Roo is configured to read `AGENTS.md`, use the portable bridge there too. |
| Kilo Code | `.kilocode/rules/supply-chain-guard.md` and/or `AGENTS.md` | Add a Kilo rule with the bridge. Kilo also supports `AGENTS.md`-style context in current docs, so prefer the portable bridge when sharing across tools. |
| Continue | `.continue/rules/supply-chain-guard.md` | Add a Continue rule that points to `.agents/skills/supply-chain-guard/SKILL.md`. |
| Qodo Gen | Chat Preferences custom instructions or `agents/*.toml` | Add the bridge under Custom Instructions for all messages, or create a custom agent/workflow TOML whose instructions point at the skill folder. |
| Tabnine Agent | Custom command or chat custom instructions | Create a custom command such as `/supply-chain-guard` containing the bridge, or paste the bridge into Tabnine's custom instructions if available. |
| Warp Agent Mode | `AGENTS.md` or Warp Drive Agent Prompt | Commit the portable bridge in `AGENTS.md`; optionally save the same bridge as a reusable Warp Agent Prompt. |
| Zed Agent / ACP agents | `AGENTS.md` | Use the portable bridge in `AGENTS.md`. This also works when Zed is driving compatible external coding agents. |
| Goose | `.agents/skills/supply-chain-guard/SKILL.md`, `~/.agents/skills/supply-chain-guard/SKILL.md`, `AGENTS.md`, or `.goosehints` | Goose supports portable skills. For project use, commit the skill folder and bridge; for global use, copy the skill to `~/.agents/skills/supply-chain-guard/`. |
| SWE-agent | Task prompt or harness-level instruction file | SWE-agent deployments vary. Include the bridge in the task prompt or harness instructions, and mount the `.agents/skills/supply-chain-guard/` folder into the workspace. |
| Augment Code | Rules / Guidelines | Add a rule or guideline with the bridge and keep the full skill in `.agents/skills/`. |
| Trae | Project rules or `.trae/skills/supply-chain-guard/` if available | Prefer a project rule pointing at `.agents/skills/supply-chain-guard/SKILL.md`. If your Trae version supports skills, copy the folder to `.trae/skills/supply-chain-guard/`. |
| Mistral Vibe | `.vibe/skills/supply-chain-guard/SKILL.md`, `~/.vibe/skills/supply-chain-guard/SKILL.md`, or `AGENTS.md` | Copy the skill folder to Vibe's project or global skills directory. Keep the `AGENTS.md` bridge at repo root for agents that rely on repository instructions. |

Minimal tool-specific bridge file:

```md
# Supply Chain Guard

Use `.agents/skills/supply-chain-guard/SKILL.md` before any task that touches dependencies, lockfiles, package-manager commands, project generators, CI actions/workflows, caches, artifacts, release jobs, IDE extensions, MCP servers, AI-agent tools, or installer scripts.

Load only the relevant reference file from `.agents/skills/supply-chain-guard/references/` when detail is needed. Do not install, update, execute, publish, or approve a dependency/tooling change when the skill says to stop for human approval.
```

## Start using it

After installing, explicitly invoke the skill once in a project:

```text
Use $supply-chain-guard before installing, updating, scaffolding, or executing any dependency-provided tooling in this repo. First inspect the manifests and lockfiles, then tell me what protections are missing.
```

You can also paste the shorter starter prompt from `prompt.md`.

For humans, the fastest manual use is:

1. Read `supply-chain-guard/SKILL.md`.
2. Open the reference file that matches your task.
3. Apply the checklist before running dependency commands.

## Recommended companion controls

This skill makes agents more careful, but it is only one layer. For stronger protection, pair it with:

- Install-time malware blocking, registry proxying, or package intelligence controls on developer machines and CI runners.
- Project package-manager defaults such as `ignore-scripts=true`, exact versions, frozen installs, and committed lockfiles.
- Native package-age gates such as npm `min-release-age`, pnpm `minimumReleaseAge`, Yarn `npmMinimalAgeGate`, Bun `minimumReleaseAge`, Deno `minimumDependencyAge`, uv `exclude-newer`, and pip `--uploaded-prior-to`.
- Isolated dev containers, Codespaces, VMs, or short-lived runners for dependency work.
- Dependency review, vulnerability and malware alerts, code scanning, secret scanning with push protection, signed commits, repository rulesets, and package provenance/attestation checks.
- Human review for dependency updates, especially patch releases from high-impact packages.

Use third-party tools only when they fit the user's environment, budget, and trust model. This skill keeps the package-age policy at the agent decision layer so it remains useful without any specific hosted product.

## Sources and inspirations

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
- [Aikido Safe Chain](https://github.com/AikidoSec/safe-chain) as design inspiration for install-time blocking and package-age checks
- [TanStack: npm supply-chain compromise postmortem](https://tanstack.com/blog/npm-supply-chain-compromise-postmortem)
- [GitHub Well-Architected: Defending against dependency supply chain attacks](https://wellarchitected.github.com/library/application-security/recommendations/managing-dependency-threats/)
- [GitHub Docs: About supply chain security](https://docs.github.com/en/code-security/concepts/supply-chain-security/about-supply-chain-security)
- [GitHub Docs: About dependency review](https://docs.github.com/en/code-security/concepts/supply-chain-security/about-dependency-review)
- [GitHub Docs: Secure use reference for GitHub Actions](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub Docs: Artifact attestations](https://docs.github.com/actions/concepts/security/artifact-attestations)
- [NIST SSDF SP 800-218 v1.1](https://csrc.nist.gov/pubs/sp/800/218/final)
- [npm Docs: Config](https://docs.npmjs.com/cli/v11/using-npm/config)
- [npm Docs: Trusted publishing](https://docs.npmjs.com/trusted-publishers/)
- [npm Docs: Generating provenance statements](https://docs.npmjs.com/generating-provenance-statements/)
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

Keep the main skill concise and durable. Add ecosystem-specific detail to `references/`. Add incident-specific package lists to issues or advisories, not to `SKILL.md`, because compromised package sets change quickly.
