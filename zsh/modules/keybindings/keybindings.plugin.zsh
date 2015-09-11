bindkey '^L'    push-input 
bindkey '\e[A'  history-search-backward 
bindkey '\e[B'  history-search-backwardstory-search-forward
# bindkey '^[[H'  beginning-of-line                              # Home key
# bindkey '^[[F'  end-of-line                                    # End key
bindkey '^[[3~' delete-char

# Allow for more robust search browsing throughout the command line history
# bindkey 'ESC[A' history-search-forward
# bindkey 'ESC[B' history-search-backward
