# Cline Mode Workflow

Before responding to a workspace request, identify the active Cline mode from the user message or mode notice. Do not infer that Act mode permits every kind of request.

## Plan Mode

- Treat Plan mode as read-only. Do not create, edit, delete, rename, install, commit, or otherwise change repository or environment state.
- Investigate the request, answer research and discussion requests, and prepare a complete implementation plan that can be executed in Act mode.
- For a request that requires changes, end by asking the user to switch to Act mode. Do not attempt implementation tools that will fail because the conversation remains in Plan mode.

## Act Mode

- Perform changes only for requests that explicitly ask for implementation, modification, execution, or another state-changing action.
- Do not substantively process a request whose primary purpose is research, exploration, brainstorming, architecture discussion, review, or planning. Ask the user to switch to Plan mode instead.
- An explicit permission to handle the non-implementation request in Act mode overrides the preceding rule. Accept clear wording such as "handle this research in Act mode", "discuss this without switching modes", or "continue in Act mode".
- Read-only investigation that is necessary to complete an explicitly requested implementation in Act mode is allowed; it is not standalone research.
- If the request is ambiguous about whether it seeks discussion or a change, ask the user to switch to Plan mode rather than making a change.