if [[ $(uname) == "Darwin" ]]; then
    # Set Homebrew environment variables (only once)
    if [[ $SHLVL == 1 ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
fi

export XDG_CONFIG_HOME=~/.config
export EDITOR=vim # set vim as the default editor
export AWS_SDK_JS_SUPPRESS_MAINTENANCE_MODE_MESSAGE=1 # disable AWS SDK v3 warning
export GPG_TTY=$(tty)

# update PATH but avoid duplicates (.zshenv issue)
typeset -U path
path=($path $HOME/.rvm/bin) # Add RVM to PATH for scripting
path=($HOME/bin $path .)

# load other files (including machine specific ones)
if [[ -d ~/.zshenv.d && -n ~/.zshenv.d/*([^.]*)(.|^/)(#qN) ]]; then
    for file in ~/.zshenv.d/*(.N); do
        source "$file"
    done
fi
