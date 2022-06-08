# Prevent multiple sourcing
[ -n "$UTIL_ARGS" ] && return || readonly UTIL_ARGS=1

# Check if number of args match 
check_args(){
		local expects received 
		expects=$1; shift
		received=$1; shift

		if ! [ $expects -eq $received ]; then return 1; fi
		return 0
	}

# At least n args
least_args(){
		local expects received 
		expects=$1; shift
		received=$1; shift

		if ! [ $expects -le $received ]; then return 1; fi
		return 0
	}
