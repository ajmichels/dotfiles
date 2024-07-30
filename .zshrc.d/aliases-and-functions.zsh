# custom aliases
alias ls='eza -l --git --icons'
alias cat=bat
alias less='bat --pager=less'
alias fgrep='fgrep -n --color=always';
alias sha='openssl sha1';
alias rsync="rsync --exclude-from ~/.rsync-exclude $*";
alias sizes='du -sh * | sort -n'
alias handbrake='HandBrakeCLI'
alias sql=fisql
alias mvim='mvim -v'
alias vim='nvim'
alias decolorize='sed "s/\x1B\[[0-9;]\{1,\}[A-Za-z]//g"'
alias mdfind='mdfind -onlyin "$PWD"'
alias tree='eza -l --tree --git --icons -I node_modules\|coverage\|vendor\|build\|dist'
alias watch-tree='watch -c "eza -l --git --tree --icons --color=always $*"'

# print terminal colors
alias show-colors='for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""'

# serve directory via http - `run-http PORT [SUBDIRECTORY]`
alias run-http='docker run --rm -v "$PWD/$2:/usr/share/nginx/html" -p "8080:$1" nginx:latest'

# Generate lower case UUID
uuid () { uuidgen | tr "[:upper:]" "[:lower:]" }

# Create directory structure and then change to it
md () { mkdir -p "$@" && cd "$@"; }

# Change to directory then list contents
cl () { cd $* && ls; }

function prompt_zsh_shell_level() {
    if [[ -n "$TMUX" ]]; then
        level=$(($SHLVL - 1))
        #promptPrefix='tmux'
    else
        level=$SHLVL
        #promptPrefix='%n@%M'
    fi

    p10k segment -f yellow -t "s${level}"
}

function prompt_tmux_check() {
    if [[ -n "$TMUX" ]]; then
        p10k segment -f blue -t "tmux"
    fi
}
