#! /bin/csh -f

# Useful wrapper script for crappy Starteam command interface.
# usages:
#        st.csh CMD DIR [OPTIONS... ] [ FILES ...]

set cmd = $1

shift

set dir = $1

shift

# use -is in OPTIONS for recurse on subdirs

stcmd30 $cmd -nologo -p USER:PASSWORD@SERVER:1024/MetraTech/VIEW/Development/$dir -rp ~/mt -eol on $*
