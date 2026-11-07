---
name: clj-implement-review-loop
description: Coordinate persistent implementation and review subagents when the user requests an iterative implementation and code review loop.
---

- **Establish scope.** Identify the task, constraints, review base and acceptance checks from the request and context. The main agent coordinates; assigned workers perform their roles without restarting this orchestration. Preserve unrelated user changes.

- **Implement.** Launch one implementation subagent, inheriting conversation context when available. It owns implementation and tests. Have it report changes, check results and known limitations, then pause edits for review.

- **Review independently.** Read [clj-code-review](../clj-code-review/SKILL.md). Launch one review subagent with fresh context: the original task, requirements, constraints, review scope/base, source access and notes path. Include an explicit `$clj-code-review` instruction and the skill's absolute file path in its task. Have it read and follow that file as the already-delegated reviewer, without another handoff. It owns the review notes and reads the implementation without modifying it. Do not initially supply the implementer's conclusions or self-assessment.

- **Discuss and respond.** Relay the complete review to the same implementation agent. It may accept a concern while rejecting its remedy, proposing a simpler fix or justified limitation with evidence. Agents may communicate directly; otherwise relay faithfully. Escalate decisions requiring user judgment.

- **Keep fixes proportionate.** Give both agents this rule: explain the concrete scenario, consequence and relevance to agreed scope. Compare a proposed fix with a simpler approach or documented limitation, weighing maintenance and testing costs. A real edge case does not automatically justify complexity; rarity alone does not excuse severe consequences or broken requirements.

- **Recheck.** Resume the same reviewer with the revised code, responses and check results. It verifies fixes and pushback against source, checks for regressions, and records each concern's disposition in the notes. Alternate implementation and review; do not review while edits continue. Keep both agents for subsequent rounds.

- **Finish on evidence.** Finish when both agents accept the same final code, required checks pass, and concerns are fixed, refuted or justifiably deferred within the agreed scope. Record the reasons and remaining limitations. Do not waive requirements to close the loop. Agreement alone is not verification; missing checks stay explicit.

- **Bound the loop.** Unless the user specifies otherwise, allow up to three review rounds. Stop earlier if evidence stops advancing a disagreement. At a limit or blocker, report the current state and unresolved concerns without claiming completion. Summarize changes and verification and link the review notes. Explicitly surface deferred concerns and accepted limitations in the final response, with reasons and remaining risks.
