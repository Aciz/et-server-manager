#!/usr/bin/env bash
set -euo pipefail

if ! source "$HOME"/scripts/paths.sh 2>/dev/null; then
	echo "Could not source 'paths.sh', please make sure it's located in '$HOME/scripts/', or edit the source location."
	exit 1
fi

instance="$1"

pidfile="$STATE_PATH/${instance}.pid"
stopfile="$STATE_PATH/${instance}.stop"
restartfile="$STATE_PATH/${instance}.restart"

# cleanup in case last shutdown was not a clean one
rm -f "$stopfile" "$restartfile" 2>/dev/null

mkdir -p "$(dirname "$pidfile")"
echo $$ >"$pidfile"
trap 'rm -f "$pidfile"' EXIT

source "$INSTANCES_PATH/${instance}.sh"

while true; do
	"$BINARY" \
		+set fs_basepath "$BASEPATH" \
		+set fs_homepath "$HOMEPATH" \
		+set fs_game "$GAME" \
		+set net_port "$PORT" \
		+exec "$SERVER_CFG" \
		"${EXTRA_ARGS[@]}"

	status=$?

	# stop if requested
	if [[ -f "$stopfile" ]]; then
		rm -f "$stopfile"
		break
	fi

	# restart if requested
	if [[ -f "$restartfile" ]]; then
		rm -f "$restartfile"
		continue
	fi

	if [[ "$status" -ne 0 ]]; then
		# TODO: save crashlog
		echo "[$(date)] $NAME ($PORT) exited unexpectedly (status code $status), restarting..."
	fi

	sleep 5
done
