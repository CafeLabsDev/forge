# Forge

A pattern — and a ready-to-use set of Claude Code subagents — for orchestrating
a team of specialists that accelerates the **Build** phase of a new product or
MVP: one orchestrator agent that runs discovery, decides which specialists to
involve, delegates to them, and synthesizes their output back to you.

Extracted and generalized from a real, working setup used to ship production
MVPs — not a theoretical framework.

## Quick start

```bash
git clone <this-repo> forge
cd forge
./scripts/setup-symlinks.sh
```

This symlinks every agent in `agents/` into `~/.claude/agents/`, so Claude Code
picks them up as subagent types. Say something like "I want to start a new
project" or "I have an idea for an app" to trigger the `orchestrator` agent.

## Why

Running an entire project through a single, generic agent means every decision
— product validation, UX, mobile implementation, backend architecture, CI/CD,
testing — competes for the same context window and the same undifferentiated
prompting. Splitting the work into an orchestrator plus focused specialists
gives each concern its own isolated context, its own minimal tool access, and
its own model tier (cheap by default, escalated only where a decision is
expensive or hard to reverse).

## How it works

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full pattern:
the orchestrator/specialist split, the delegation flow, the model selection
heuristic, and how the orchestrator maintains its own roster over time.

## Status

Architecture documented, 8 generalized specialist agents included: `orchestrator`,
`product`, `design`, `mobile`, `backend`, `frontend-web`, `devops`, `qa`.

## License

TBD.
