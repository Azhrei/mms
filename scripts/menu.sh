#!/bin/bash

# This script is a generalized menu system.

FILENAME=${1##*/}
if [[ "$FILENAME" != *.menu ]]; then
    echo >&2 "Program error: '$FILENAME' does not appear to be a menu file."
    exit 1
fi

# Look in each directory in MENUPATH to locate the file.  Once found,
# make sure it's readable and then... Just do it!

OFS=$IFS
IFS=":"
set -- $MENUPATH
IFS=$OFS
if (( $# < 1 )); then
    echo >&2 "Program error: 'MENUPATH' must be set."
    exit 3
fi

for dir
do
    current=$dir/$FILENAME
    if [[ -f "$current" ]]; then
	if [[ ! -r "$current" ]]; then
	    echo >&2 "Program error: '$current' is not a readable file."
	    exit 4
	fi
	. "$current"
	PS3="${FILENAME%.menu}> "
	PS3="${PS3##*/}"
	select opt in "${Menu[@]}"
	do
	    # We can't rely solely on REPLY since it may not have been valid
	    # input (such as typing in two numbers with a space between them).
	    # By checking '$opt', we know a valid selection was made.
	    if [[ "$opt" != "" ]] && (( REPLY > 0 && REPLY <= ${#Menu[@]} )); then
		eval "${Cmds[REPLY]}"
	    else
		echo >&2 "Invalid selection: '$REPLY'"
	    fi
	done
    fi
done
