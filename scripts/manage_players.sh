#!/bin/bash

# This script allows an authorized user to add new player entries to the
# list of allowed players.  This script simply manages adding and removing
# entries from that directory.

. setup.sh

# Trim the ".sh" and add ".menu", then look in MENUPATH to find the menu.
menu.sh ${0%.sh}.menu
