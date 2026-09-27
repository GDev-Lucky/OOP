# AGENTS.md

## Repository Practice

- Treat source, tests, and tool configuration as authoritative; inspect relevant files before editing.
- Preserve existing project boundaries, conventions, and public APIs. Do not infer an architecture or introduce new dependencies without evidence or an explicit user request.
- Keep changes focused on the requested task. Do not modify unrelated source, generated output, secrets, or machine-specific files.
- Identify and run the repository's applicable formatting, linting, type-checking, test, build, and diff checks. Report unavailable validation plainly.

## Memory Workflow

1. Read `.ai/tasks/current.md` and its linked task record on resumption.
2. Run `.ai/tools/archive-tasks.ps1` before retrieving prior work.
3. Read `.ai/README.md`, then load only task-relevant project, decision, guide, summary, and source context.
4. Keep task records and `.ai/tasks/current.md` synchronized.
5. Validate with applicable repository checks, `git diff --check` when Git is available, and `.ai/tools/validate-workflow.ps1` after changing workflow files.
6. Use `.ai/tools/retrieve-context.ps1` whenever it can save tokens.

## Token Discipline

- Treat `.ai/config.psd1` limits as ceilings, not targets. Use the smallest sufficient context and stop retrieving as soon as the task is understood.
- Search before reading broadly. Read only relevant line ranges, batch independent reads and checks, and never reread unchanged content without a specific need.
- Use `.ai/tools/retrieve-context.ps1` instead of manually loading multiple memory files whenever prior context is needed and retrieval can reduce tokens.
- Keep plans to at most five concise steps. Keep progress updates to one or two sentences and report only decisions, blockers, or validation results.
- Do not paste large file contents, diffs, search results, or routine command output into responses. Summarize them and cite file paths or line ranges.
- Default to a concise final response of at most 400 words unless the user requests detail or additional explanation is necessary for correctness.
- Do not sacrifice correctness, required validation, or explicit user requirements to save tokens.

## Rules

- Follow the Memory Workflow and Token Discipline sections for every repository task.
- Record confirmed durable decisions in `.ai/decision/`; dated decision files are append-only.
- Keep memory factual, compact, and linked to authoritative source paths. Do not record speculative designs, routine command output, private history, or unrelated application details.
- Do not add source-project-specific memory from another repository. Initialize this repository's memory only from facts verified in this repository.
