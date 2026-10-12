# Global working defaults

Apply these defaults to coding tasks. Repository and directory-level `AGENTS.md`
instructions take precedence on conflict. Use PR and commit rules only when the
project uses those workflows. Scale the process to the task's risk.

Before starting a task, read `~/.codex/AGENTS.local.md` if it exists. That
user-managed file adds machine-specific preferences and takes precedence over
these global defaults; repository guidance still takes precedence over both.
If `CODEX_HOME` is set, look for `AGENTS.local.md` there instead.

## Approach

- Read applicable repository guidance and the code being changed, including callers.
- Before non-trivial changes, state the intended outcome and scope in one or two sentences.
- Make the smallest complete change that solves the task.
- Remove obsolete complexity introduced or replaced by the change.
- Prefer existing capabilities over new configuration, dependencies, or abstractions.
- Preserve necessary validation, security, and failure handling.
- Mention unrelated bugs or cleanup opportunities; do not fix them in the same change without authorization.

## Design

- Share code when it represents the same rule and should evolve together, not merely similar syntax.
- Prefer clear interfaces and sensible defaults that prevent realistic mistakes.
- Keep guardrails proportionate to the likelihood and impact of failure.

## Debugging

- Reproduce the failure where practical.
- Isolate which change fixes the cause, not just the symptom.
- Remove unsuccessful experiments before submitting the fix.
- Explain uncertainty about causality and any workaround retained because isolation was impractical.

## Testing and verification

- Run relevant formatting, validation, and tests before presenting a change.
- Test intended behavior, meaningful boundaries, and realistic failure modes.
- Check integration boundaries when the change affects how components work together.
- Match verification effort to risk; avoid tests that merely mirror implementation details.

## Commits and pull requests

- Keep changes small, coherent, and independently reviewable.
- Follow the repository's commit conventions and configured `commit.template` when present.
- Otherwise use Conventional Commits, an imperative subject, and one logical change per commit.
- Explain the problem, resulting behavior, important tradeoffs, and verification in PR descriptions.
- Leave merging to me unless I explicitly ask you to merge.

## Reviews

- Review behavior, design, and consequential risks before style; let tooling handle mechanical checks.
- Support findings with concrete impact and evidence.
- Distinguish blocking concerns from optional suggestions and personal preferences.
- After review feedback, assess the complete resulting change and rerun affected checks.
- Keep documentation aligned with the final behavior.

## Git safety and permissions

- Preserve unrelated local changes and commits.
- Never force-push or rewrite shared history.
- Do not amend commits you did not create.
- Ask before `reset --hard`, deleting branches, or discarding user work.
- Obtain explicit authorization before deleting user data, destructive migrations, production or shared-infrastructure changes, or publishing externally.
- Authorization already given for that action counts; routine edits and removal of obsolete tracked code within the agreed scope do not need repeated confirmation.
- Continue authorized work; ask when a missing decision materially changes the result.

## Secrets and dependencies

- Read `.env`, credential, or private-key files only when necessary for the task; prefer inspecting variable names or redacted values.
- Never print secrets or include sensitive data in commits, logs, PR descriptions, or external requests.
- Keep credentials, machine-local state, and generated caches out of version control.
- Add a dependency only when it clearly improves on existing project or platform capabilities for the task.
- Follow repository version-pinning and lockfile conventions; avoid unpinned remote code execution.
- Routine package installation and network access needed for authorized work do not require another confirmation.
- Ask before sending private code or data to a new external service or installing software outside the task's scope.

## Environment

- Prefer `rg` for file and text searches when available.
- If standalone RTK is available, use `rtk` on PATH to compact routine status, logs, builds, and test output.
- Read and search code being edited with raw commands; also run `git diff --check` raw to preserve whitespace diagnostics.
- When Serena is available, read its initial instructions and activate the current project before using its semantic tools.
- Use Codebase Memory for repository indexing and structural queries when available; use Serena for precise symbol navigation and editing.
- Ponytail and Caveman are optional skills; activate them when requested rather than forcing terse output for every task.
- Check the OS and shell before choosing commands; do not assume GNU flags on macOS.
- Use the project's existing tools and package manager rather than assuming Homebrew or a particular shell.

## Communication

- Explain outcomes and tradeoffs concisely in plain language.
- Distinguish verified results from inferences and assumptions; state what remains unverified.
