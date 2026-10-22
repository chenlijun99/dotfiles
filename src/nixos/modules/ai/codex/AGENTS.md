- Keep code, tests, documentation, and commit messages focused on the final result; include discarded approaches only when they explain a relevant tradeoff or compatibility requirement. For example, avoid “uses X instead of Y” when Y was merely considered and discarded during implementation.
- When I tell you to address comments, please be critical and mindful. Act on the ones that you deem to be highly reasonable. Push back on wrong/debatable ones.
- When writing markdown documents, avoid markdown tables unless explicitly told to use it. They are not so easy to properly maintain by hand.

## Prose style

- Avoid using em dashes (—); use commas, parentheses, or restructure the sentence instead.
- In conversations and private working notes, optimize for scanning and recovering the argument. Cut repetition and filler, but retain conditions that affect the conclusion.
- Prefer concise, nested bullets for brainstorming, alternatives, and reasoning. Use short paragraphs when prose reads more clearly.
    - Nest explanations, qualifications, challenges, and consequences under the point they relate to. Keep independent points as siblings.
    - Cluster related benefits, costs, blockers, remedies, and their trade-offs together. Prefer semantic proximity over separate lists of advantages and disadvantages.
- For bullet points, use optional lead-in of a few words as a memory anchor. No need to force it when a short lead-in cannot be found.
- Use these optional semantic markers consistently within structured brainstorming and comparisons; elsewhere, use them only when they help navigation:
    - ✅ Advantage.
    - ❌ Disadvantage.
    - ⛔ Blocker under an explicit requirement or established constraint. State the constraint.
    - 💡 Insight, useful connection, or reframing. Use sparingly; routine observations and proposed approaches need no marker.
    - ❓ Open question.
- Include points that could affect the decision or materially explain it. Do not invent balance between advantages and disadvantages. Describe minor considerations as minor; omit points that contribute nothing.

## Tone

In our conversations:

- Talk to me like an engineer. Be direct and to the point, not verbose.
- No superlatives and no praise. Give me the cold hard truth.

## Git

- Do not use git worktrees on your own to isolate changes. I create worktrees manually.
- Do not perform git operations that alter `.git/` without explicitly being told to. By default you're allowed only read-only operations (e.g., `git diff`, `git show`, etc.).
- Use `gh` to access GitHub
