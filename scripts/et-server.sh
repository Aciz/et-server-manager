#!/usr/bin/env bash
set -euo pipefail

if ! source "$HOME"/scripts/paths.sh 2>/dev/null; then
	echo "Could not source '$HOME/scripts/paths.sh'. Please make sure the path is correct, or edit the source location."
	exit 1
fi

cmd="${1-}"
instance="${2-}"

print_help() {
	echo "Usage: $0 [start|stop|restart] <instance>" >&2
	exit 1
}

[[ -n "$cmd" ]] || print_help
[[ -n "$instance" ]] || print_help

instance_file="$INSTANCES_PATH/${instance}.sh"
pidfile="$STATE_PATH/${instance}.pid"

if [[ ! -f "$instance_file" ]]; then
	echo "Unknown instance '${instance}'"
	echo "Available instances in '$INSTANCES_PATH':"

	for f in "$INSTANCES_PATH"/*.sh; do
		basename "${f%.sh}"
	done

	exit 1
fi

start_server() {
	# make sure we're not already running
	if [[ -r "$pidfile" ]] &&
		kill -0 "$(cat "$pidfile")" 2>/dev/null; then
		echo "Server '$instance' is already running."
		return
	fi

	if tmux has-session -t "$instance" 2>/dev/null; then
		echo "Reusing existing tmux session '$instance'."
	else
		echo "Creating a new tmux session '$instance' for the server."
		tmux new-session -d -s "$instance"
	fi

	echo "Starting server instance '$instance'..."
	tmux send-keys -t "$instance" "$SCRIPT_PATH/run-server.sh $instance" Enter
}

stop_server() {
	if ! tmux has-session -t "$instance" 2>/dev/null; then
		echo "No tmux session found for instance '$instance'."
		return
	fi

	echo "Stopping server instance '$instance'..."
	touch "$STATE_PATH/${instance}.stop"

	# prefix with semicolon so any potential existing input in
	# server console does not interfere with the quit command
	tmux send-keys -t "$instance" ";quit" Enter

	# let the server shut down cleanly, as systemd sends SIGKILL
	# to all child processes once the main process exits
	while kill -0 "$(cat "$pidfile")" 2>/dev/null; do
		sleep 0.5
	done
}

restart_server() {
	if ! tmux has-session -t "$instance" 2>/dev/null; then
		echo "No tmux session found for instance '$instance'."
		return
	fi

	touch "$STATE_PATH/${instance}.restart"
	tmux send-keys -t "$instance" ";quit" Enter
}

case "$cmd" in
start)
	start_server
	;;
stop)
	stop_server
	;;
restart)
	restart_server
	;;
*)
	print_help
	;;
esac
