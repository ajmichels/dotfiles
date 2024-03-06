if [[ $SHLVL == 1 ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export XDG_CONFIG_HOME=~/.config
export EDITOR=vim # set vim as the default editor

# update PATH but avoid duplicates (.zshenv issue)
typeset -U path
path=($path $HOME/.rvm/bin) # Add RVM to PATH for scripting
path=($HOME/bin $path .)

# create a named directory ~prj
prj=~/projects
: ~prj

# load other files (including machine specific ones)
if [[ -d ~/.zshenv.d ]]; then
    source ~/.zshenv.d/*
fi
