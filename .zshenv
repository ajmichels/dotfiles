# REMINDER
#
# `.zshenv' is sourced on all invocations of the shell, unless the -f,--no-rcs
# option is set. It should contain commands to set the command search path,
# plus other important environment variables. `.zshenv' should not contain
# commands that produce output or assume the shell is attached to a tty.

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
