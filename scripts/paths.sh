#!/usr/bin/env bash

# edit to match your environment

# directory where 'et-server.sh' and 'run-server.sh' are located
SCRIPT_PATH=/srv/et/scripts

# directory containing the instance configurations
INSTANCES_PATH=/srv/et/instances

# directory to write temporary state files in
# make sure the user running the script has write permissions here!
STATE_PATH=/run/$(whoami)
