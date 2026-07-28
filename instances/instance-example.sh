#!/usr/bin/env bash

# Fill you your instance details here, and rename this file.
# The filename you choose will be the "instance" name you pass to the scripts,
# and the tmux session for the server will be created using that name.
# NOTE: this is a shell script, so you may perform variable substitutions here

# Instance name, this is only used in logging if the server unexpectedly exits.
NAME="Instance example"
# Path to the server executable
BINARY=
# Path used for 'fs_basepath'
BASEPATH=
# Path used for 'fs_homepath'
HOMEPATH=
# The mod to run ('fs_game')
GAME=
# Port to use ('net_port')
PORT=27960
# Server config to execute
SERVER_CFG=
# Optional, any additional arguments passed to the server on startup.
# You may leave this empty.
EXTRA_ARGS=()
