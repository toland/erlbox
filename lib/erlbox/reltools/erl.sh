#!/bin/sh

RUNNER_BASE_DIR=`pwd`

# Parse out release and erts info
START_ERL=`cat $RUNNER_BASE_DIR/releases/start_erl.data`
ERTS_VSN=${START_ERL% *}
APP_VSN=${START_ERL#* }

ROOTDIR=$RUNNER_BASE_DIR
BINDIR=$ROOTDIR/erts-$ERTS_VSN/bin
EMU=beam
PROGNAME=`echo $0 | sed 's/.*\///'`
CMD="$BINDIR/erlexec"
export EMU
export ROOTDIR
export BINDIR
export PROGNAME

exec $CMD -boot $ROOTDIR/erts-$ERTS_VSN/bin/erl ${1+"$@"}