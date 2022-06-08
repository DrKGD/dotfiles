# Prevent multiple sourcing
[ -n "$UTIL_COLOR" ] && return || readonly UTIL_COLOR=1

loc="$HOME/.config/scripts/"
. "$loc/util.args.sh"
. "$loc/util.log.sh"
. "$loc/util.string.sh"

# Convert #AABBCC to RGB values
hex2rgb(){ 
	$(check_args 1 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
	printf "%d %d %d\n" 0x${1:1:2} 0x${1:3:2} 0x${1:5:2}; 
}

# hex2 * ratio + hex2 * (1 - ratio)
_mix(){
	$(check_args 3 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
	printf "%02x" 0x$(echo "obase=16;ibase=16;($1 * $3 + $2 * (1 - $3)) / 1" | bc)
}

# Mix two hex6 colors with complementary ratio 
# e.g. 0.25 means $firstColor * 0.25 + $secondColor * 0.75
hex6_mix(){ 
	$(check_args 3 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
	local lhs rhs ratio
	lhs=$(toUpper $1); shift; 
	rhs=$(toUpper $1); shift; 
	ratio=$(toHex $1); shift;

	printf "#%s%s%s\n" "$(_mix ${lhs:1:2} ${rhs:1:2} ${ratio})" \
		"$(_mix ${lhs:3:2} ${rhs:3:2} ${ratio})" \
		"$(_mix ${lhs:5:2} ${rhs:5:2} ${ratio})"
}

# Darken
hex6_darken(){
	$(check_args 2 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
	hex6_mix $1 '#000000' $2
}

# Lighten
hex6_lighten(){
	$(check_args 2 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
	hex6_mix $1 '#FFFFFF' $2
}

# Range
# Returns n colors ranging from $1 to $2
# hex6_range(){
# 	$(check_args 4 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
# 	local from to i n prefix
# 	from=$(toUpper $1); shift; 
# 	to=$(toUpper $1); shift; 
# 	n=$1; shift;
# 	prefix=$1; shift;
#
# 	for ((i = 0; i < $n + 1; ++i)); do
# 		export ${prefix}_$i="$(hex6_mix $from $to $( echo "scale=3;1 - (1 / $n * $i)" | bc ))"; done
# }


_gradient(){
		echo "$(hex6_mix $1 $2 $( echo "scale=5;1 - (1 / $3 * $4)" | bc ))" 
	}

# Range
# Returns shades ranging from $1 to $2 to $3 ... $n
# n means 'n colors between $1 and $2'
hex6_range(){
	$(least_args 4 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
	local i j n prefix from to index
	n=$(($1 + 1)); shift;
	prefix=$1; shift;

	# Initialize first cycle, expecting at least 2 colors
	from=$(toUpper $1); shift;
	to=$(toUpper $1); shift;

	# Start from i=0 up to $n
	for ((i = 0; i <= $n; ++i)); do
		index=$(printf '%02d' $i);
		echo "# ${prefix}_$index $(_gradient $from $to $n $i)";
		export ${prefix}_$index=$(_gradient $from $to $n $i); done

	# Continue with the rest
	j=$(($n + 1))
	while (($#)); do
		# Shift to next color
		from=$to
		to=$1; shift;

		# Start from i=1 up to $n
		for ((i = 1; i <= $n; ++i)); do
			index=$(printf '%02d' $(($i + $j - 1)));
			echo "# ${prefix}_$index $(_gradient $from $to $n $i)";
			export ${prefix}_$index=$(_gradient $from $to $n $i); done

		# Index
		j=$(( $j+$n ));
	done
}

# Range w-b
hex6_range_bw(){
	$(check_args 3 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
	hex6_range $1 $2 '#000000' $3 '#FFFFFF'
}


