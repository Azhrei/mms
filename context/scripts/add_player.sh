#!/bin/bash

# This script creates a keypair for distribution to a player.

# This function has two options:
# 1. Create a public/private keypair for a new player.
# 2. Import a public key provided by a player.

. setup.sh

# Trim the ".sh" and add ".menu", then look in MENUPATH to find the menu.
menu.sh ${0%.sh}.menu
