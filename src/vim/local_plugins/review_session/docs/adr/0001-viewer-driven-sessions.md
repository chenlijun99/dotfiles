# Viewer-driven review workspaces

A review session collects activity while the reviewer navigates ordinary versioned views, including intermediate commits and index/worktree differences. Capture an exact file pair only when creating a thread or explicitly marking it reviewed; loading a session or navigating a viewer must not enroll comparisons, persist snapshots or otherwise write session storage. This keeps navigation independent of review bookkeeping while preserving immutable original context, exact-pair reviewed status and a session-wide hint that another pair of the same file was reviewed.

Threads and publication drafts belong to the workspace, independent of viewers. Original thread context opens in a configurable preferred viewer (codediff by default), with retained snapshots as fallback; incompatible publication coordinates require an explicit new anchor or PR-wide summary.
