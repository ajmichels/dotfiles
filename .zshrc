# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# Make sure Zinit is installed
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# NVM options
export NVM_AUTO_USE=true # automatically switch node versions based on .nvmrc files
export NVM_COMPLETION=true # load zsh auto-completions for NVM
# export NVM_LAZY_LOAD=true # NOTE: this doesn't seem to work correctly

# Zinit packages
zinit ice depth=1
zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
# zinit light jeffreytse/zsh-vi-mode
zinit light lukechilds/zsh-nvm

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q # replay cache completion

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

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

# To customize prompt, run `p10k configure` or edit ~/.zshrc.d/p10k.zsh.
[[ ! -f ~/.zshrc.d/p10k.zsh ]] || source ~/.zshrc.d/p10k.zsh
