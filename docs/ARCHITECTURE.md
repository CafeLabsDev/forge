# Architecture

Agent Forge is a pattern for orchestrating a team of specialized subagents on top
of Claude Code (or any agent runtime with an equivalent subagent/tool-delegation
primitive) to accelerate the **Build** phase of a new product or MVP: one
orchestrator agent that runs initial discovery, decides which specialists to
involve, delegates to them, and synthesizes their output back to the user.

## Core pattern: orchestrator + specialists

### The orchestrator

- Runs on the highest-capability model available (e.g. Opus) — it is the only
  role that makes whole-project architecture decisions. That happens rarely per
  project, so the stronger reasoning is worth the cost.
- Triggers automatically when the user signals they're starting a new project or
  want to validate a product idea — defined declaratively via the agent's
  `description` trigger, no explicit command needed.
- Conducts an initial discovery before involving any specialist: problem,
  target audience, platform(s), timeline, and budget constraints (e.g. "must run
  on free tiers" vs. paid infrastructure). When a design specialist is in scope,
  it also asks about design ambition — safe/proven (native UI patterns, lower
  risk, faster) vs. bold/experimental (custom visual identity, more time/risk,
  more differentiation) — skipping the question for disposable MVPs, where fast
  validation matters more than form, and defaulting to safe/proven.
- Decides which specialists to involve — only the ones relevant to the scope,
  never all of them by default.
- Has authority to decide technically on its own, always optimizing in this
  order: cost (prefer a plausible free tier), solo-maintainer simplicity,
  reasonable scalability without over-engineering, current stack practices.
- Surfaces decisions and trade-offs before proceeding. Never asks trivial
  questions, but also never unilaterally makes an expensive or hard-to-reverse
  decision (e.g. backend choice, monetization model) without exposing the
  options first.

### Specialists

Each specialist is a separate subagent file (for example: `product`, `design`,
`mobile`, `backend`, `frontend-web`, `devops`, `qa` — the roster is a starting
point, not a fixed list) with:

- a `name` and a `description` containing a clear trigger — the phrases that
  should activate it;
- the minimal `tools` needed for its scope;
- a `model` — the mid-tier model by default, escalated to the top-tier model
  only when the role makes expensive or hard-to-reverse decisions (the
  canonical example is a backend/data-architecture specialist choosing the
  persistence layer).

Specialists run in **isolated context** — they never see the conversation that
led to the delegation. The orchestrator must summarize the agreed scope
explicitly in the delegation call; nothing is implicit.

## Delegation flow

1. The orchestrator runs discovery and agrees on scope with the user.
2. It picks the relevant specialists and delegates to each of them, passing the
   scope summary explicitly (specialists start cold, with no memory of the
   conversation).
3. Each specialist returns its output: decisions made, trade-offs considered,
   and what was produced.
4. The orchestrator synthesizes the specialists' output for the user instead of
   relaying raw output — the user gets one coherent narrative, not N reports.

## Model selection heuristic

- Default every subagent to the mid-tier model — cheaper, and fast enough for
  well-scoped implementation work.
- Escalate to the top-tier model only for roles that make whole-project or
  hard-to-reverse decisions: the orchestrator itself, and any specialist that
  owns data/infrastructure architecture.
- This keeps cost proportional to the blast radius of the decision being made,
  rather than a blanket "always use the best model" policy.

## Self-maintaining roster

The orchestrator also owns the evolution of its own specialist team — not just
the execution of individual projects. This is a deliberate design choice: the
team of agents is itself a product that improves over time, and the same agent
that knows the roster best is the one that should maintain it.

- **Updating a specialist**: edit its file directly (prompt, tools, model). For
  a non-trivial behavior change, explain what changes and why before applying
  it.
- **Splitting a specialist in two**: propose the new split of responsibilities
  first — never split unilaterally without confirmation. Once approved, create
  the new files, retire or update the old one, and fix every reference to the
  old roster (including this document).
- **Creating a new specialist**: follow the existing pattern — frontmatter with
  a clear trigger `description`, minimal `tools` for the scope, and the
  mid-tier model by default (escalate only if the decision is expensive or hard
  to reverse, same rule as above).
- After any add/rename/remove under the agents directory, re-run the symlink
  setup script (see below) — otherwise the runtime won't see the change.
- Keep the roster documentation in sync with the real files — it's the team's
  source of truth for what exists and why.

## Wiring into Claude Code

Subagent definitions are plain Markdown files with YAML frontmatter (`name`,
`description`, `tools`, `model`) under `agents/`. `scripts/setup-symlinks.sh`
symlinks each of them into `~/.claude/agents/` so Claude Code picks them up as
available subagent types — see that script for the exact mechanism, and re-run
it any time an agent file is added, renamed, or removed.

## Extending the roster

The specialist list in this repo (`agents/`) is a generalized starting point
extracted from a real, working team of agents used to ship production MVPs. It
is deliberately not tied to any specific product domain or tech stack — treat
each specialist file as a template to adapt to your own stack, team roles, and
decision-making priorities.
