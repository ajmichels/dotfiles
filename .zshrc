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
# username@hostname | shell-level prompt-count command-count history-num | current-directory prompt
export PROMPT=$'\n''%B%F{cyan}%n@%M %F{white}%b| s$SHLVL p%i c$cmdcount h%h | %F{yellow}%~ %F{white}'$'\n''$ '

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

eval "$(gh completion -s zsh)"
#export PATH="/usr/local/opt/mysql-client/bin:$PATH"

# Allow for using CTRL+<ARROW> to move through words in current command line
bindkey "^[f" forward-word
bindkey "^[b" backward-word

source ~/.config/broot/launcher/bash/br

# Run RVM so that we can automatically switch Ruby versions
source ~/.rvm/scripts/rvm

# Ensure NVM can automatically switch NodeJS versions
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# custom aliases
alias ls='exa -l --git'
alias cat=bat
alias less='bat --pager=less'
alias fgrep='fgrep -n --color=always';
alias sha='openssl sha1';
alias rsync="rsync --exclude-from ~/.rsync-exclude $*";
alias sizes='du -sh * | sort -n'
alias handbrake='HandBrakeCLI'
alias sql=fisql
alias vim='mvim -v'
alias decolorize='sed "s/\x1B\[[0-9;]\{1,\}[A-Za-z]//g"'
alias mdfind='mdfind -onlyin "$PWD"'
alias tree='exa -l --tree --git -I node_modules\|coverage\|vendor\|build\|dist'

alias foobar='echo a:$0 b:$1 c:$2'
alias run-http='docker run --rm -v "$PWD/$2:/usr/share/nginx/html" -p "8080:$1" nginx:latest'
uuid () { uuidgen | tr "[:upper:]" "[:lower:]" } # Generate lower case UUID
md () { mkdir -p "$@" && cd "$@"; } # Create directory structure and then change to it
cl () { cd $* && ls; } # Change to directory then list contents

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# pnpm
export PNPM_HOME="~/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# load other files (including machine specific ones)
if [[ -d ~/.zshrc.d ]]; then
    source ~/.zshrc.d/*
fi
