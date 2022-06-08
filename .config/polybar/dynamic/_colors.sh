. $HOME/.config/scripts/util.colors.sh
. $HOME/.config/scripts/util.args.sh
. $HOME/.config/scripts/util.string.sh

_pfx='_color'

defc(){
		$(check_args 2 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
		export ${_pfx}_${1}=$2
	}

# NOTE: Don't really know if ill need this 
namec(){
		$(check_args 1 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
		local name; name="$(echo ${_pfx}_${1})"; printf "%s" "${name}"

	}

# NOTE: Don't really know if ill need this 
getc(){
		$(check_args 1 $#) || { log_msg 0 "Wrong number of arguments\n"; exit 1; }
		local name; name="$(echo ${_pfx}_${1})"; printf "%s" "${!name}"
	}

# Predefine some colors 
defc 'orange'								'#ff9507'
defc 'american_orange'			'#fb8c00'
defc 'red_orange'						'#f76d47'
defc 'canary'								'#ffeb00'
defc 'blue'									'#006af8'
defc 'azure'								'#179aff'
defc 'cherry'								'#ff004d'
defc 'strawberry' 					'#fc5a8d'
defc 'cream'								'#fffdd0'
defc 'lavander'							'#faeff1'
defc 'flame'								'#e4572e'
defc 'black'								'#000000'
defc 'white'								'#ffffff'
defc 'turquoise'						'#00f5cc'
defc 'green'								'#17ff7c'
defc 'violet'								'#47007d'
defc 'dark_gray'  					'#060606'

# Make the bar completly transparent
defc 'transparent'					'#00000000'

