setopt HIST_VERIFY # print history command before executing it (eg. !! or !:3)
setopt INC_APPEND_HISTORY # add to history as commands execute
setopt EXTENDED_HISTORY # include start and execution time in history
setopt HIST_IGNORE_DUPS # do not capture repeated adjacent commands
setopt HIST_EXPIRE_DUPS_FIRST # remove duplicate commands first when history is full
setopt HIST_FIND_NO_DUPS # do not include any dups (event non-adjacent) in find results (up arrow or search)
setopt HIST_IGNORE_SPACE # commands run with a leading space will not be stored in history
setopt HIST_NO_STORE # do not store history or fc commands in the history (inspecting history will not contribute to history)
setopt HIST_NO_FUNCTIONS # do not store function definitions in the history
setopt CORRECT # attempt to correct mistyped commands
setopt PROMPT_SUBST # add more feature for customizing the prompt

# Set the PROMT apperance
[[ $cmdcount -ge 1 ]] || cmdcount=1
preexec() { ((cmdcount++)) }
# alter prompt when in tmux
if [[ -n "$TMUX" ]]; then
    level=$(($SHLVL - 1))
    promptPrefix='tmux'
else
    level=$SHLVL
    promptPrefix='%n@%M'
fi

# username@hostname | shell-level prompt-count command-count history-num | current-directory prompt
export PROMPT=$'\n''%B%F{cyan}$promptPrefix %F{white}%b| s$level p%i c$cmdcount h%h | %F{yellow}%~ %F{white}'$'\n''$ '

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# The following lines were added by compinstall zstyle ':completion:*' completer _complete _ignored
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' ''
zstyle :compinstall filename '~/.zshrc'
autoload -Uz compinit
compinit
# End of lines added by compinstall

# GitHub CLI command completion
eval "$(gh completion -s zsh)"

# expose `br` function for running broot
source ~/.config/broot/launcher/bash/br

# Initialize zoxide - a better cd command
eval "$(zoxide init --cmd cd zsh)"

# Run RVM so that we can automatically switch Ruby versions
if [[ -f ~/.rvm/scripts/rvm ]]; then
    source ~/.rvm/scripts/rvm
fi

# load other files (including machine specific ones)
if [[ -d ~/.zshrc.d ]]; then
    for file in ~/.zshrc.d/*; do
        source "$file"
    done
fi
