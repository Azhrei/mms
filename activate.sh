#!/bin/bash

# Concatenates all of the public keys under $PUBKEYS and creates the
# authorized_keys file needed by SSH.

# Sets relevant environment variables and changes directory
source ./setup.sh

# Causes a terminal window to open in the GUI and fills it with text
# on each call.  If the function is never called, the window is never
# opened.  It prompts the user to press Enter to close the window.
# (Although this script always calls this function, even if everything
# worked.)
function status {
    # If the first parameter is entirely numeric, it's an exit status.
    # Otherwise, this function returns instead of exiting.
    exit="$1"
    if [[ "$exit" == *[!0-9]* ]]; then
	echo >>"$LOGFILE" 2>&1 "$@"
    else
	shift
	echo >>"$LOGFILE" 2>&1 "$@"
	echo >>"$LOGFILE" ""
	echo >>"$LOGFILE" "You may close this window now."
	exit $exit
    fi
}

TMP=$(mktemp XXXXXXXX)
trap 'rm "$TMP"; exit' 0 1 2 3 15
LOGFILE=activate.log
exec >"$LOGFILE" 2>&1
x-terminal-emulator -e "tail -f '$LOGFILE'"
status "Logging to '$LOGFILE' started at $(date)"
status " "

# Make a list of valid key types and compare them against the contents
# of the players' key files.
types=( $(ssh -Q key) )
declare -A VALID_TYPES
for i in "${types[@]}"
do
    VALID_TYPES[$i]=1
done

# Any key files that start with a period are normal SSH logins, NOT player
# or GM logins for MapTool.  That means they can be used to obtain a shell
# prompt for debugging of scripts and such.
for file in "$PUBKEYS"/.*.pub "$PUBKEYS"/*.pub
do
    # Skip subdirectories
    [[ -d "$file" ]] && continue

    # Skip unreadable files, but produce a warning
    if [[ ! -r "$file" ]]; then
	status "Unreadable file skipped: '$file'"
    	continue
    fi

    base="${file##*/}"
    base="${base%.pub}"
    # The filename is going to be put into an environment variable, so it
    # cannot contain spaces, tabs, or a variety of punctuation symbols.
    # Here, we're going with just straight-up alhpanumerics only.
    if [[ "$base" == *[!.a-zA-Z_0-9]* ]]; then
	status 99 "Invalid file name: '$file'.  Must be alphanumerics only."
    fi
    output_line=""
    while read type pubkey comment
    do
    	# Some basic sanity checks on the content.
	if [[ "${VALID_TYPES[$type]}" != "1" ]]; then
	    status 1 "Invalid key type in '$file': '$type'"
	fi
	if (( ${#pubkey} < 64 )); then
	    status 2 "Unknown key type in '$file': '$type' -- key too short"
	fi
	if [[ "$output_line" != "" ]]; then
	    status 3 "Too many keys in '$file'."
	fi
	# If the base filename starts with a period, don't force the command
	if [[ "$base" == .* ]]; then
	    command=""
	else
	    command="~/.ssh/mt-serve"
	fi
	output_line="port-forwarding,${command:+command="$command",}environment=\"REMOTE=$base\" $type $pubkey $comment"
    done < "$file"
    if [[ "$output_line" == "" ]]; then
	status 4 "No keys in '$file'.  Check permissions and content."
    else
	echo "$output_line"
	status "Added key in '$file'."
    fi
done > "$TMP"

cat "$TMP" > "$BASEDIR/authorized_keys"
chmod 600 "$BASEDIR/authorized_keys"

status 0 "Configuration updated!"
