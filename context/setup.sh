#!/bin/bash

# Common script that initializes the shell environment.

cd /home/maptool/.ssh || exit 99
export BASEDIR=$PWD

export MENUPATH=$BASEDIR/menus

# Sanitize the environment first.
# (Not yet.  We'll do this when development is done.)
#PATH=/bin:/usr/bin:/sbin:/usr/sbin
export PATH=$PWD/scripts:$PATH

# All players have a keypair assigned to them.  Their public keys are stored
# here and are concatenated together to form the 'authorized_keys' file used
# by the normal SSH login process.
export PUBKEYS=$BASEDIR/player-keys
