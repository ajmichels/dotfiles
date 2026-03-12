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
path=($HOME/bin $path)
path=($HOME/.local/bin $path)

# load other files (including machine specific ones)
if [[ -d ~/.zshenv.d && -n ~/.zshenv.d/*([^.]*)(.|^/)(#qN) ]]; then
    for file in ~/.zshenv.d/*(.N); do
        source "$file"
    done
fi

# Disabling global RC files for ZSH on MacOS
# I found that the /etc/zprofile file is running MacOS specific path_helper
# which is adding the following paths but also reorder the paths that already
# exist
if [[ $(uname) == "Darwin" ]]; then
    setopt no_global_rcs
    path=($path /usr/local/bin)
    # Not really sure what these are but they look important...
    path=($path /System/Cryptexes/App/usr/bin)
    path=($path /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin)
    path=($path /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin)
    path=($path /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin)
fi
