# Only attempt to include Homebrew when running on MacOS
if [[ $(uname) == "Darwin" ]]; then

    # Add Homebrew bin directory to PATH for scripting
    path=(/opt/homebrew/bin $path)

    # Set Homebrew environment variables (only once)
    if [[ $SHLVL == 1 ]]; then eval "$(brew shellenv)"; fi

fi
