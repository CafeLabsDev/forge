# Forge

A pattern — and a ready-to-use set of Claude Code subagents — for orchestrating
a team of specialists that accelerates the **Build** phase of a new product or
MVP: one orchestrator agent that runs discovery, decides which specialists to
involve, delegates to them, and synthesizes their output back to you.

Extracted and generalized from a real, working setup used to ship production
MVPs — not a theoretical framework.

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed and authenticated.
- `git`, and a POSIX shell (the setup script is bash).

## Quick start

```bash
git clone <this-repo> forge
cd forge
./scripts/setup-symlinks.sh
```

This symlinks every agent in `agents/` into `~/.claude/agents/`, so Claude Code
picks them up as subagent types. Say something like "I want to start a new
project" or "I have an idea for an app" to trigger the `orchestrator` agent.

## Example session

```
you:          I have an idea for an app that helps small gyms schedule classes
              and manage member check-ins.

orchestrator: [runs discovery] Who's the first customer — a specific gym, or
              gyms in general? What's the timeline and budget? Web, mobile, or
              both? ...

you:          One gym I already talk to, mobile only, free tier only, want
              something in 2-3 weeks.

orchestrator: [flags that "gyms in general" would've been too broad, confirms
              the narrower scope is workable in that timeline, summarizes it,
              and delegates]
              -> product: validates the hypothesis, defines v1 scope and
                 success criteria
              -> design: flows + wireframes for booking and check-in
              -> backend: data model, auth, security rules
              -> mobile: implementation
              -> qa: test plan for the critical booking/check-in path

orchestrator: [synthesizes all of the above into one coherent plan, flags any
              trade-off or push-back a specialist raised along the way]
```

Each specialist runs in its own isolated context — the orchestrator explicitly
summarizes the agreed scope when delegating, so nothing relies on a specialist
having "seen" the conversation.

## Customizing for your stack

The specialist roster is a generalized template, not a finished product for
your specific stack — expect to edit a few files before relying on it:

- **`agents/mobile.md`** assumes Flutter as a placeholder in its "Stack and
  house pattern" section — replace it with whatever mobile stack (React
  Native, native, etc.) and state-management pattern you've actually validated.
- **`agents/backend.md`** treats a free-tier BaaS (Firebase/Supabase) as a
  default starting point in its "Starting point, not a fixed rule" section —
  adjust this if your validated stack is different (a specific self-hosted
  setup, a different cloud provider, etc.).
- Update the `description` trigger phrases and any stack-specific wording in
  other specialists (`frontend-web`, `devops`) to match your team's real
  tools and conventions.

Keeping these grounded in a stack you've actually shipped with (rather than
generic advice) is what makes the specialists' domain-mastery sections useful
instead of hand-wavy — see `docs/ARCHITECTURE.md` ("Extending the roster").

## Why

Running an entire project through a single, generic agent means every decision
— product validation, UX, mobile implementation, backend architecture, CI/CD,
testing — competes for the same context window and the same undifferentiated
prompting. Splitting the work into an orchestrator plus focused specialists
gives each concern its own isolated context, its own minimal tool access, and
its own model tier (cheap by default, escalated only where a decision is
expensive or hard to reverse).

Each specialist is written to be a genuine expert in its domain, not a
compliant order-taker: every agent carries a "domain mastery" section (real
heuristics and failure modes, not generic advice) and a shared **advocate,
don't just comply** principle — it will push back, with concrete reasoning, on
a request that's technically doable but suboptimal or actively harmful, and
hold the line on a short list of non-negotiables (security, data integrity,
whether the MVP can test its hypothesis at all) unless given a real
justification to override them.

## How it works

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full pattern:
the orchestrator/specialist split, the delegation flow, the model selection
heuristic, the advocate-don't-comply principle, and how the orchestrator
maintains its own roster over time.

## Status

Architecture documented, 10 specialist agents included:

| Agent | Role |
|---|---|
| `orchestrator` | Discovery, scoping, delegation, roster maintenance |
| `product` | Hypothesis validation, MVP scope, success criteria |
| `design` | UX flows, wireframes, visual identity |
| `mobile` | Mobile implementation |
| `frontend-web` | Web implementation |
| `backend` | Data/infrastructure architecture |
| `devops` | CI/CD, deploy, environments |
| `qa` | Test plan and minimum viable coverage |
| `security` | Independent security review before launch |
| `analytics` | Turning success criteria into real instrumentation |

## License

TBD.
