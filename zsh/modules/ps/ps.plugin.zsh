psup() { # uptime of given process or everything if none given
	if [ $1 ]; then # argument passed -> search for it
			ps -ax -o etime,command -c | grep $1 ;
	else # no argument
		ps -ax -o etime,command -c | less ;
	fi
}

alias psa="ps auxc | less"
