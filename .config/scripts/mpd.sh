#!/usr/bin/env bash

readonly delay=${1:-0.2};
readonly maxwidth=${2:-30};
readonly spacer=$(printf -- ' %.0s' $(seq 1 $(($maxwidth / 2))))

zscroll --delay $delay \
		--length $maxwidth \
		--scroll-padding "$spacer" \
		--update-check true "mpc current" &

wait

