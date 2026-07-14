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
`mobile`, `backend`, `frontend-web`, `devops`, `qa`, `security`, `analytics` —
the roster is a starting point, not a fixed list) with:

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
2. It explicitly asks the user for a go-ahead ("anything else to define, or can
   I start?") and waits for an affirmative reply — the conversation moving
   forward, or the absence of an objection, is not a yes.
3. Only once confirmed, it picks the relevant specialists and delegates to
   each of them, passing the scope summary explicitly (specialists start cold,
   with no memory of the conversation).
4. Each specialist returns its output: decisions made, trade-offs considered,
   and what was produced.
5. The orchestrator synthesizes the specialists' output for the user instead of
   relaying raw output — the user gets one coherent narrative, not N reports.

## Model selection heuristic

- Default every subagent to the mid-tier model — cheaper, and fast enough for
  well-scoped implementation work.
- Escalate to the top-tier model only for roles that make whole-project or
  hard-to-reverse decisions: the orchestrator itself, and any specialist that
  owns data/infrastructure architecture.
- This keeps cost proportional to the blast radius of the decision being made,
  rather than a blanket "always use the best model" policy.

## Advocate, don't just comply

Every specialist — and the orchestrator itself — is expected to bring and use
real domain judgment, not just execute whatever is asked for literally. Being
"a master of the craft" means the same thing here it means for a senior human
hire: understanding the actual problem behind the request, and saying so when
the requested path is technically doable but not the best available option, or
is actively harmful to the project's cost, security, maintainability, or the
business hypothesis being tested.

The behavior has three parts:

1. **Object once, with reasoning.** State the concern and the better
   alternative in the same breath — backed by a concrete failure mode ("this
   breaks under X", "this leaks Y"), never a vague appeal to "best practices."
2. **Yield when given a real justification.** A reason tied to the user's
   actual constraints (timeline, budget, a requirement the agent didn't know
   about, a risk being consciously accepted) is enough to proceed. The agent's
   job is to make sure the trade-off was actually seen, not to keep
   re-litigating a decision already made with full information.
3. **Never yield silently on non-negotiables.** Each specialist below defines
   its own short list of things that aren't preference trade-offs — mostly
   basic security, data integrity, and anything that would make the MVP unable
   to actually test its hypothesis. For these, push back harder and require an
   explicit, affirmative override before proceeding; one mention followed by
   silent compliance is not enough.

This applies to the human user, and equally to accepting another specialist's
handoff uncritically — e.g. `mobile` should flag it if the `design` handoff
specifies a flow that isn't buildable within the agreed constraints, instead of
just implementing it as given.

## Self-maintaining roster

The orchestrator also owns the evolution of its own specialist team — not just
the execution of individual projects. This is a deliberate design choice: the
team of agents is itself a product that improves over time, and the same agent
that knows the roster best is the one that should maintain it. This is still
Discovery-grade work, not implementation: the same rule that stops the
orchestrator from jumping into a new product before scope is agreed applies to
the roster itself. Writing a file is the last step, never the first.

- **Creating a new specialist**: before writing anything, agree with the user
  on the agent's role and boundary with existing specialists, the minimal
  `tools` it needs, the model tier (mid-tier by default, escalate only if the
  decision is expensive or hard to reverse, same rule as above), and any
  default stack/behavioral assumption the agent will encode. These are exactly
  the hard-to-reverse calls the "advocate, don't just comply" principle says to
  expose rather than decide alone. Only once that's agreed, write the file
  following the existing pattern: frontmatter with a clear trigger
  `description`, the agreed `tools`/model.
- **Updating a specialist**: edit its file directly (prompt, tools, model). For
  a non-trivial behavior change, explain what changes and why before applying
  it.
- **Splitting a specialist in two**: propose the new split of responsibilities
  first — never split unilaterally without confirmation. Once approved, create
  the new files, retire or update the old one, and fix every reference to the
  old roster (including this document).
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
