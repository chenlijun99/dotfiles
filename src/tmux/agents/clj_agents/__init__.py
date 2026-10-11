"""Hook-free coding-agent overview for tmux.

Nothing is installed into the agents: detection reads the pane title and the
pane screen, and the picker previews the real pane by moving the tmux client.

The modules are libraries; `cli.py` is the entry point (`clj_agents scan`,
`clj_agents popup`).
"""

import sys

# Keep bytecode out of the source tree, and out of the read-only store copy.
sys.dont_write_bytecode = True

__version__ = "0.1.0"
