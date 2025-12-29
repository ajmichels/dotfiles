# Got ideas for these configurations from this video
# https://www.youtube.com/watch?v=mmqDYw9C30I

# Initialize fzf - fuzzy finder
# - set up key bindings
# - set up completion
if ! type "dpkg" > /dev/null || dpkg --compare-versions "$(dpkg-query -f '${Version}' -W fzf)" ge "0.48.0"; then
    eval "$(fzf --zsh)"
fi

# Use `fd` as the default command
# include hidden files, exclude file in .git dir, and file that match .gitignore patters
export FZF_DEFAULT_COMMAND='fd --strip-cwd-prefix --hidden --exclude .git'
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_CTRL_T_OPTS="
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'
    "
export FZF_CTRL_R_OPTS="
    --preview 'echo {}'
    --preview-window down:10:wrap
    --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --color header:italic
    --header 'Press CTRL-Y to copy command into clipboard'
    "
export FZF_ALT_C_OPTS="
    --preview 'tree -C {}'
    "

# Use fd for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details
_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
}
