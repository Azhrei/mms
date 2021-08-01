#!/usr/bin/env python3

# Concatenates all of the public keys under $PUBKEYS and creates the
# "authorized_keys" file needed by SSH.

# The input is the most recent CSV file in the $PUBKEYS directory.
# The CSV file is in this format:
#Timestamp,SSH Public Key,Discord Name and #,Email Address
# We don't want the timestamp, but the rest is good data for us.

# That's because we want the output of this script to be:
#port-forwarding,${command}environment="REMOTE=$discord" $pubkey $email
# with one line for each entry in the CSV (skipping the header, of course).

# The "command" variable should contain 'command="mt-serve"' but only for
# non-administrative uses.  (The idea is that the admin would include their
# own key in the CSV and it would be treated differently.  More than one admin
# can be specified.)

import csv
import os
import subprocess
import sys
import tempfile
import time

# Sets relevant environment variables and changes directory
import setup


LOGFILE = "activate.log"
try:
    logfile = open(LOGFILE, "wt", encoding="utf-8")
except Exception as ex:
    print(f"During open('{LOGFILE}', 'wt'): {ex}", file=sys.stderr)
    sys.exit(1)

# Make a list of valid key types for comparison against the contents
# of the players' keys.
key_types = setup.ssh_key_types()

# Keep track of various checks
environment = { 'darwin': None, 'isatty': None }


def status(*args):
    """
    Causes a terminal window to open in the GUI and fills it with text
    on each call.  If the function is never called, the window is never
    opened.  It prompts the user to press Enter to close the window.
    (Although this script always calls this function, even if everything
    worked.)

    If the first parameter is entirely numeric, it's an exit status.
    Otherwise, this function returns instead of exiting.
    """
    # Only need to do this check once
    if environment['darwin'] is None:
        environment['darwin'] = setup.PLATFORM == "darwin"
        if not environment['darwin']:
            subprocess.run(['x-terminal-emulator', '-e', 'tail', '-f', LOGFILE])
        environment['isatty'] = sys.stdin.isatty()

    # Should I add a time stamp to the logfile records?  Should I switch to
    # use module `logging`?
    try:
        exit_status = int(args[0])
        print(args[1:], file=logfile)
        if environment['isatty']:
            print(args[1:], file=sys.stdout)
        print("", file=logfile)
        print("You may close this window now.", file=logfile)
        sys.exit(exit_status)
    except ValueError:
        print(args, file=logfile)
        if environment['isatty']:
            print(args, file=sys.stdout)


def isValidKey(k):
    """
    Returns a boolean indicating whether the string stored in param `k`
    appears to be a valid SSH key.  There are checks for the number of fields,
    for the length of the hash, and for the type of key.
    """
    fields = k.split()
    if len(fields) != 3 or len(fields[1]) < 64:
        return False
    if fields[0] not in key_types:
        return False
    return True


def write_one_key(options, key):
    print(options, key, file=tmpfile)


status(f"Logging to '{LOGFILE}' started at {time.asctime()}")
status(" ")

with tempfile.NamedTemporaryFile(mode="wt", delete=False, dir=setup.BASE_DIR) as tmpfile:
    # Immediately protect the contents of the temporary file
    os.chmod(tmpfile.name, 0o600)

    # First, ensure there is even a keys file available.
    csv_file = None
    newest = 0
    for file in os.listdir(setup.PUB_KEYS):
        if file.endswith(".txt"):
            path_name = setup.PUB_KEYS + "/" + file
            status(f"Checking '{path_name}'.")
            last_access = os.path.getmtime(path_name)
            if last_access > newest:
                status(f"  {path_name} is newer than {csv_file}.")
                newest = last_access
                csv_file = path_name
    if not csv_file:
        status(1, f"Did not find '.txt' file of keys in {setup.PUB_KEYS}")

    # Okay, now we can process any admin keys.
    port_forwarding = 'port-forwarding'
    counter = 1
    for file in os.listdir(setup.ADMIN_KEYS):
        # This allows files stored by having Firefox download them from a
        # GDrive location, as well as .pub files uploaded from a Un*x box.
        if file.endswith(".txt") or file.endswith(".pub"):
            key_file = setup.ADMIN_KEYS + "/" + file
            status(f"admin:{key_file}:checking format of contents")
            with open(key_file, encoding="utf-8") as k:
                for lnum, line in enumerate(k, 1):
                    # Some basic sanity checks first
                    if not isValidKey(line):
                        status(f"admin:{key_file}:{lnum}:unrecognized key format")
                        continue
                    environ = f'environment="REMOTE=admin{counter}"'
                    counter += 1
                    write_one_key(",".join([port_forwarding, environ]), line)
                    status(f"admin:{key_file}:{lnum}:wrote one key")

    # Do all player/GM keys that have been uploaded.
    command = 'command="~/.ssh/mt-serve"'
    with open(csv_file, encoding="utf-8") as k:
        for lnum, row in enumerate(csv.reader(k), 1):
            # Some basic sanity checks first
            if len(row) != 4:
                status(f"player:{key_file}:{lnum}:number of fields != 3")
                continue
            if not isValidKey(row[1]):
                status(f"player:{key_file}:{lnum}:unrecognized key format")
                continue
            environ = f'environment="REMOTE={row[2].replace("#", "_")}"'
            write_one_key(",".join([command, port_forwarding, environ]), row[1])
            status(f"player:{key_file}:{lnum}:wrote one key")

try:
    os.replace(setup.BASE_DIR + "/authorized_keys", setup.BASE_DIR + "/authorized_keys.old")
    os.replace(tmpfile.name, setup.BASE_DIR + "/authorized_keys")
    status(0, "Updated 'authorized_keys'.")
except Exception as err:
    status(1, f"Can't replace 'authorized_keys' file: {err}")
