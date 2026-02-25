# source ~/.pwndbg/gdbinit.py
python
import os
_peda = os.path.expanduser('~/.peda/peda.py')
if os.path.exists(_peda):
    gdb.execute('source ' + _peda)
end
# source ~/.gdbinit-gef.py

# for OSX Sierra 10.12 or later with SIP enabled:
set startup-with-shell off

# alternate (old) gdbinit file
# src: https://raw.githubusercontent.com/gdbinit/Gdbinit/master/gdbinit
