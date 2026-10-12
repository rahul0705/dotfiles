# Working preferences

- Read the repository's guidance and follow its existing conventions. Understand the intended outcome and surrounding code before changing or reviewing it.
- Make the smallest complete change. Challenge whether new configuration, dependencies, or abstractions are needed; prefer existing capabilities and remove obsolete complexity. Preserve necessary validation, security, and failure handling.
- Share code when it represents the same rule and should evolve together. Similar-looking code alone does not justify coupling independent concepts.
- Prefer clear interfaces, sensible defaults, and automated checks that prevent realistic mistakes. Scale guardrails to the likelihood and impact of failure; avoid layers for hypothetical misuse.
- When debugging, reproduce the failure where practical and isolate which change fixes its cause. Remove unsuccessful experiments. If causality cannot be established, explain the uncertainty and any retained workaround.
- Keep unrelated local changes intact. Never commit credentials, machine-local state, or generated caches.
- Work in small, coherent, reviewable pull requests. Explain the problem, resulting behavior, important tradeoffs, and verification. Leave merging to me unless I explicitly ask you to merge.
- Run relevant formatting, validation, and tests before presenting a change. Test intended behavior and realistic failure modes, including integration boundaries when affected; scale evidence to risk and state what you did not verify.
- Review behavior, design, and consequential risks before style. Let tooling handle mechanical checks. Explain findings with concrete impact and evidence; distinguish blocking concerns from optional suggestions and personal preferences.
- After review feedback changes the implementation, assess the complete resulting change and rerun affected checks. Keep documentation aligned with the final behavior.
- Continue authorized work without repeatedly asking for confirmation. Ask when a missing decision materially changes the result.
- Explain outcomes and tradeoffs concisely, using plain language.

## Sources

These preferences distill my engineering articles. Apply judgment rather than treating them as a checklist for every change. Consult the linked articles when deeper context is useful; website access is not required for routine tasks.

- [Code Reviews](https://www.rahulmohandas.com/blog/2018-10-08-peer-reviews/)
- [Did You Fix the Bug—or Just Move It?](https://www.rahulmohandas.com/blog/2026-08-20-did-you-fix-the-bug/)
- [Duplication Is Cheaper Than the Wrong Abstraction](https://www.rahulmohandas.com/blog/2026-08-17-duplication-vs-coupling/)
- [The Best Code Is Sometimes the Code You Don't Write](https://www.rahulmohandas.com/blog/2026-09-14-the-best-code-you-dont-write/)
- [Make the Wrong Thing Hard to Do](https://www.rahulmohandas.com/blog/2026-09-30-make-the-wrong-thing-hard-to-do/)
