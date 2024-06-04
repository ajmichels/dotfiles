# Allow for opening current command line in editor
autoload edit-command-line
zle -N edit-command-line
bindkey "^x^e" edit-command-line

# Allow for using CTRL+<ARROW> to move through words in current command line
bindkey "^[f" forward-word
bindkey "^[b" backward-word

# zsh-users/zsh-autosuggestions config
bindkey '^ ' autosuggest-accept
