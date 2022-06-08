# Prevent multiple sourcing
[ -n "$UTIL_LOG" ] && return || readonly UTIL_LOG=1

# Source from the current folder
loc="$HOME/.config/scripts/"
. "$loc/util.args.sh"

# Base indent line 
readonly _indent=${baseindent:=0}
readonly _tabsize=${tabsize:=2}

# Indent utility
doindent (){ for ((i=1;i<=$1 ;i++)); do printf ' '; done; }

# Log functions
log_msg(){
		local indent format
		amount=$(( $_tabsize * $(( $1 + $_indent )) )); shift
		format="${1}"; shift

		printf "$(doindent ${amount})${format}" "$@"
	}
