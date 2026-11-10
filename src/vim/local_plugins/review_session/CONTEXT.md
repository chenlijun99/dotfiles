# Review workspace

A disposable workspace collects review discussions, reviewed file pairs and selected publication drafts across source versions.

## Language

**Session**:
A workspace collecting review activity independently of any editor, agent or fixed comparison.
_Avoid_: Comparison, agent session

**File pair**:
The exact old and new versions of one file change, including paths and relevant metadata.
_Avoid_: File path, commit range

**Reviewed**:
The current file pair was explicitly marked reviewed in this session.

**Another revision reviewed**:
A different pair of the same file was explicitly reviewed in this session, without implying ordering or partial coverage.
_Avoid_: Previously reviewed, partially reviewed

**Pending**:
The current pair has no reviewed mark and the session has no mark for a different pair of that file.

**Thread**:
A discussion with an immutable original review, file or source-range anchor.

**Publication anchor**:
An explicitly selected location for publishing a thread, retained separately from its original anchor.

**Draft**:
A specific message revision explicitly selected for publication.
