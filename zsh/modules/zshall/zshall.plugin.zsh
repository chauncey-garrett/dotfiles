help(){
    #This function used to call the "bash" builtin.
    #bash -c "help $@"

    #Better way: look it up in the man pages. I often look up "test" which doesn't give a usefull result,
    #so I added that as a special case.
    if [[ $1 == "test" ]]; then
        man -P "less -p'^CONDITIONAL EXPRESSIONS$'" zshall
    else
        man -P "less -p'^ *$@ '" zshall
    fi
}
