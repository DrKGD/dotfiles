# Prevent multiple sourcing
[ -n "$UTIL_STRING" ] && return || readonly UTIL_STRING=1

# Source from the current folder
loc="$HOME/.config/scripts/"
. "$loc/util.args.sh"

# Convert arg to upper
toUpper(){
	$(check_args 1 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
	echo $1 | tr a-z A-Z
}

# Convert to hex
toHex(){
	$(check_args 1 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
	echo "obase=16;$1" | bc
}
