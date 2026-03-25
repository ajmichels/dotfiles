# custom aliases
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
alias mypath='tr ":" "\n" <<< $PATH'
alias reload='exec zsh -l'

if type "eza" > /dev/null; then
    # eza not available in some environments (eg. old Raspberry PI OS)
    alias ls='eza -l --git --icons'
    alias tree='eza -l --tree --git --icons -I node_modules\|coverage\|vendor\|build\|dist'
    alias watch-tree='watch -c "eza -l --git --tree --icons --color=always $*"'
else
    alias ls='ls -l --color=auto'
fi

if [[ $TERM == "xterm-kitty" ]]; then
    alias ssh="kitty +kitten ssh"
fi

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

rand() {
    local help
    local verbose
    local min=("0")
    local max=("9999999999999999")
    local usage=(
        "rand - returns a random integer"
        "  -h,--help - shows this message"
        "  -v,--verbose - print additional info to stderr"
        "  -n,--min - minimum value. Defaults to $min"
        "  -x,--max - maximum value. Defaults to $max"
        " "
        "NOTE: This function depends on the jr utility."
    )

    zparseopts -F -K -- \
        {h,-help}=help \
        {v,-verbose}=verbose \
        {n,-min}:=min \
        {x,-max}:=max ||
        return 1

    [[ ! -z "$help" ]] && print -l $usage && return

    if [[ ! -z "$verbose" ]]; then
        print -u2 "Min: $min[-1], Max: $max[-1]"
    fi

    echo $(jr template run --embedded "{{integer $min[-1] $max[-1]}}" 2> /dev/null)
}

# Provide an indicator of how nested the current prompt is inside of the shell
# This is for the Powerlevel10k Prompt extension
function prompt_zsh_shell_level() {
    local level=$SHLVL

    if [[ -n "$TMUX" ]]; then
        level=$(($SHLVL - 1))
    fi

    p10k segment -f yellow -t "s${level}"
}

# Check if the current prompt is running inside of tmux
# This is for the Powerlevel10k Prompt extension
function prompt_tmux_check() {
    if [[ -n "$TMUX" ]]; then
        p10k segment -f blue -t "tmux"
    fi
}

# Traverses up the tree to see if the current directory is inside of an NVM context
# This is for the Powerlevel10k Prompt extension
function prompt_my_nvm() {
    local NVMRC=".nvmrc"
    local DIR=$(pwd)
    while [[ "$DIR" != "/" && ! -f "$DIR/$NVMRC" ]]; do
        DIR=$(dirname "$DIR")
    done

    if [[ -f "$DIR/$NVMRC" ]]; then
        local NODE_VERSION=$(nvm current);
        [[ -n "$NODE_VERSION" ]] && p10k segment -f yellow -t "$NODE_VERSION";
    fi
}

# Input a URL and follow that URL through all of its redirects and output the final URL
function resolve-url() {
    local url="${1:-$(cat)}"
    curl -Ls -o /dev/null -w '%{url_effective}' "$url"
}
