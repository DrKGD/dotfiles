#!/bin/sh

if [ "$#" -ne 2 ]; then
	echo 'Wrong number of arguments supplied, aborting...'
	exit 1
fi

# Process parameters
sink=${1}; shift
step=${1}; shift
sign=${step:0:1}

# Check the sign
case ${sign}'' in
	'-') step=$(( step < -100 ? -100 : step ));;
	'+') step=$(( step > 100 ? 100 : step ));;
	*) echo 'Unsigned numbers are not allowed!' ; exit 1;;
esac

# Get current value
volume=$(pactl get-sink-volume ${sink} | awk 'NR==1{sub("%", "", $5); print $5}');

# Calculate new value
newvolume=$(( volume + step ))
newvolume=$(( newvolume < 0 ? 0 : newvolume)) 
newvolume=$(( newvolume > 100 ? 100 : newvolume)) 

# Sanity checks
[[ $newvolume =~ '^[0-9]+$' || $newvolume -gt 100 || $newvolume -lt 0 ]] \
	&& echo "Assert: newvolume is '$newvolume'" && exit 2;

echo $sign, $volume, $newvolume
echo ${sink} "${newvolume}"
pactl set-sink-volume ${sink} "${newvolume}%"
