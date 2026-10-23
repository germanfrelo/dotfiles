#!/usr/bin/env bash

# shellcheck disable=SC2250,SC2292,SC2312,SL2020 # Preserve upstream Antigravity CLI 'title.sh' script without modifications.

# Reference: https://antigravity.google/docs/cli/title

set -euo pipefail

# Read JSON payload from stdin
DATA=$(cat)

# Extract fields using jq
eval "$(echo "$DATA" | jq -r '
	"STATE=\"\(.agent_state // "idle")\"
	CWD=\"\(.workspace.current_dir // "")\"
	"
' 2>/dev/null || echo 'STATE="idle" CWD=""')"

# Try to extract CitC workspace name from CWD
if [ -n "$CWD" ]; then
	if [[ "$CWD" =~ /google/src/cloud/[^/]+/([^/]+) ]]; then
		WORKSPACE="${BASH_REMATCH[1]}"
	else
		WORKSPACE=$(basename "$CWD")
	fi
else
	WORKSPACE="unknown"
fi

# Map state to emoji
case "$STATE" in
	initializing) EMOJI="🚀" ;;
	idle) EMOJI="😴" ;;
	thinking) EMOJI="🤔" ;;
	working) EMOJI="🏃" ;;
	tool_use) EMOJI="🛠️" ;;
	*) EMOJI="🤖" ;;
esac

TITLE="$EMOJI $STATE | $WORKSPACE"

echo "$TITLE"
