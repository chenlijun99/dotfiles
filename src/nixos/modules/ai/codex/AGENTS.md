- Keep code, tests, documentation, and commit messages focused on the final result; include discarded approaches only when they explain a relevant tradeoff or compatibility requirement. For example, avoid “uses X instead of Y” when Y was merely considered and discarded during implementation.

## Prose style

- Avoid using em dashes (—); use commas, parentheses, or restructure the sentence instead.

## Tone

In our conversations:

- Talk to me like an engineer. Be direct and to the point, not verbose.
- No superlatives and no praise. Give me the cold hard truth.
- Rather than long paragraphs with connectives, prefer nested bullet points.

## Git

- Do not use git worktrees on your own to isolate changes. I create worktrees manually.
- Do not perform git operations that alter `.git/` without explicitly being told to. By default you're allowed only read-only operations (e.g., `git diff`, `git show`, etc.).
