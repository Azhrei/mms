"""
Assigns all relevant environment variables for Python scripts in this project.

Exported variables are:

    HOME        = user's home directory, typically "/home/maptool".
    PLATFORM    = "" (unless running on macOS where the value is "darwin").
    MAPTOOL_SSH = user's ".ssh" directory, typically "/home/maptool/.ssh".
                  On macOS, set to the current directory or directory of
                  the script.
    BASE_DIR    = MAPTOOL_SSH, or directory the script is in on macOS.
    MENU_PATH   = BASE_DIR/menus.
    ADMIN_KEYS  = BASE_DIR/admin-keys
    PUB_KEYS    = HOME/Downloads

Directories will not have trailing slashes, so be sure to add them.

The PATH variable is also redefined in the environment tp include
BASE_DIR/scripts.
"""

import os
import subprocess
import sys

HOME = os.getenv("HOME", "/home/maptool")

MAPTOOL_SSH = HOME + "/.ssh"
PLATFORM = ""

# For debugging purposes on macOS, it's convenient to treat the current
# directory as the user's ".ssh" directory.
if sys.platform == "darwin":
    PLATFORM = "darwin"
    command = sys.argv[0]
    if "/" in command:
        MAPTOOL_SSH = command[ :command.rfind("/") ]
    else:
        MAPTOOL_SSH = os.getcwd()

try:
    os.chdir(MAPTOOL_SSH)
except Exception as ex:
    print(f"During chdir('{MAPTOOL_SSH}'): {ex}", file=sys.stderr)
    sys.exit(99)

BASE_DIR = os.getcwd()
MENU_PATH = BASE_DIR + "/menus"
ADMIN_KEYS = BASE_DIR + "/admin-keys"

# Sanitize the environment first.
# (Not yet.  We'll do this when development is done.)
# os.putenv("PATH", "/bin:/usr/bin:/sbin:/usr/sbin")
os.putenv("PATH", BASE_DIR + "/scripts" + os.pathsep + os.getenv("PATH"))

# Keys are kept in CSV files in this directory.  The 'activate' script will
# find the most recent file in this directory that ends with ".txt" and use it
# as the CSV file player keys.  File names that qualify but are not selected
# will be listed in the log file.
PUB_KEYS = HOME + "/Downloads"


def ssh_key_types():
    types = []
    try:
        completed = subprocess.run(['ssh', '-Q', 'key'], encoding='utf-8',
                                   check=True, stdout=subprocess.PIPE)
        types = completed.stdout.split('\n')
    except subprocess.CalledProcessError as exc:
        print(f"During subprocess.run(): {exc}")
    return types
