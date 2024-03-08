# Set Homebrew environment variables (only once)
if [[ $SHLVL == 1 ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi

export XDG_CONFIG_HOME=~/.config
export EDITOR=vim # set vim as the default editor
export AWS_SDK_JS_SUPPRESS_MAINTENANCE_MODE_MESSAGE=1 # disable AWS SDK v3 warning
export GPG_TTY=$(tty)

# update PATH but avoid duplicates (.zshenv issue)
typeset -U path
path=($path $HOME/.rvm/bin) # Add RVM to PATH for scripting
path=($HOME/bin $path .)

# create a named directory ~prj
prj=~/projects
: ~prj

# load other files (including machine specific ones)
if [[ -d ~/.zshenv.d ]]; then
    for file in ~/.zshenv.d/*; do
        source "$file"
    done
fi
