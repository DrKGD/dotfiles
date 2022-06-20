#!/bin/sh

if [ "$#" -ne 1 ]; then
	echo 'Wrong number of arguments supplied, aborting...'
	exit 1
fi

# Get current workspace
ws_location="${1}"; shift
readonly currentWS=$(i3-msg -t get_workspaces \
											| jq '.[] | select(.focused==true).name' \
											| cut -d"\"" -f2)

# Save workspace
i3-save-tree --workspace "$currentWS" > "$ws_location"
