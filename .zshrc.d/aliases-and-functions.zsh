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

# serve directory via http - `run-http PORT [SUBDIRECTORY]`
alias run-http='docker run --rm -v "$PWD/$2:/usr/share/nginx/html" -p "8080:$1" nginx:latest'

# Generate lower case UUID
uuid () { uuidgen | tr "[:upper:]" "[:lower:]" }

# Create directory structure and then change to it
md () { mkdir -p "$@" && cd "$@"; }

# Change to directory then list contents
cl () { cd $* && ls; }
