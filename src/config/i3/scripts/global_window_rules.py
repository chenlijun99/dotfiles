#!/usr/bin/env python3

from i3ipc import Connection
i3 = Connection()

def focus(i3, event):
    event.container.command('focus')

i3.on('window::new', focus)
i3.main()
