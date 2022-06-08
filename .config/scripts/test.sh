#!/bin/sh

. ./util.colors.sh
. ./util.log.sh

a='#FF0000'
b='#0000FF'
c='#00FF00'

# hex6_range $a $b 5 'range'

hex6_range_bw 9 'range' $a 
# hex6_range 9 'range' $a $b $c $a
