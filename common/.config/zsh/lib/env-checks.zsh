# OS checks
function is-macos   { [[ "$OSTYPE" == darwin*  ]]; }
function is-linux   { [[ "$OSTYPE" == linux*   ]]; }
function is-bsd     { [[ "$OSTYPE" == *bsd*    ]]; }
function is-solaris { [[ "$OSTYPE" == solaris* ]]; }
function is-windows { [[ "$OSTYPE" == cygwin* || "$OSTYPE" == msys ]]; }

# Command checks
# is-installed: true if an external binary exists on PATH ($commands hash, O(1))
function is-installed       { (( $+commands[$1] )); }
# is-command-defined: true if a command exists by any means (binary, function, builtin, alias)
function is-command-defined { whence -w -- "$1" &>/dev/null; }
function is-function        { (( $+functions[$1] )); }
