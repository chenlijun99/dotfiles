---
name: clj-code-review
description: Review proposed code changes in a dedicated subagent, using repository guidance and a written scope and coverage checklist.
---

- **Scope and handoff.** Establish the review target, comparison base and scope from the request and context. If unclear, ask the user and wait. Otherwise announce what will be reviewed, then launch one dedicated review subagent with this skill, the scope, relevant user constraints, source access and notes path. If already the delegated reviewer, proceed below instead of repeating the handoff. If delegation is unavailable, report the limitation.

- **Plan first.** Before investigating, the reviewer records the target, base, intended behavior, scope and a preliminary, change-specific checklist in `review-notes.md` or the requested Markdown file. Preserve existing notes and update the checklist as you learn.

- **Use repository context.** Read applicable `AGENTS.md` and consult relevant skills, specifications and documentation. Record the guidance used in the notes file: file paths, relevant sections or rules, and why each applies. Check changes against their guidance and compare similar implementations. Distinguish requirements from conventions; precedents guide judgment but can also be wrong. Load only relevant material.

- **Behavior and contracts.** Check requirements, failure paths and connected callers. Follow changed interfaces through producers and consumers; check that separately maintained formats or mappings agree.

- **High cohesion and low coupling.** Keep complexity belonging to one concern close together. Consider class and function boundaries and ownership: would a proposed split isolate a responsibility or scatter its details?

- **Naming and readability.** Check whether file, type, function, variable and test names communicate their role and relevant distinctions. Compare names with actual contents and behavior. Flag misleading, ambiguous or inconsistent names with concrete examples and explain what becomes clearer; avoid preference-only renaming.

- **Visual structure.** Check whether statement order, blank lines and local grouping expose the code's logical steps. Keep closely related operations together and separate distinct phases or cases. Look for dense blocks that hide structure and excessive separation that obscures dependencies. Explain how a proposed grouping helps local reasoning; prefer small layout changes when sufficient, without demanding helper extraction solely to shorten a function.

- **Reuse.** Look for existing helpers and decisions maintained in multiple places. Compare their contracts before suggesting sharing; weigh saved maintenance against added dependencies and abstraction costs.

- **Necessity.** Look for code that serves no current requirement. Before suggesting removal, verify what behavior depends on it. Extra code can confuse maintainers by suggesting a purpose that does not exist.

- **Tests and automation.** Check that assertions would catch realistic bugs in the changed behavior. When possible, tests shouldn't be tightly coupled to the implementation. Suggest test regrouping when it makes related cases easier to find or understand, following the file's conventions. Verify how and when important tests run, including CI, nightly or justified manual runs.

- **Cost.** Assess data structures and algorithms against actual operations and input bounds. Look for work that can be skipped entirely for some configurations or inputs, such as when a feature is disabled. Distinguish demonstrated problems from optional optimizations whose benefit may not justify the effort.

- **Additional reviewers.** Use one review subagent by default. If the user requests independent reviewers, the lead reviewer may delegate complementary angles, such as behavior/verification and design/cost. Give them the same scope and source context; angle workers do not delegate further. The lead reviewer checks claims and remedies against source, seeks counterexamples, and consolidates duplicate concerns.

- **Report.** Give locations, evidence and consequences, prioritized by impact. Separate defects from useful discussions and incidental pre-existing issues. For concerns you raise, distinguish requirement violations, implementation choices and unclear requirements. Suggest justified remedies; explain consequential tradeoffs without requiring a definitive recommendation. Skip mechanical style enforced by tools; semantic naming and visual grouping still require review judgment. Avoid finding quotas.

- **Finish the record.** Update the Markdown checklist with evidence for completed checks, reasons for inapplicable checks, and missing evidence for unverified checks. Link it in the final review. A planned check is not a completed check.
