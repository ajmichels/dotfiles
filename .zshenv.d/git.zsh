if command -v 'batcat' &> /dev/null; then
    # for certain debian environments there `bat` will be installed as `batcat`
    # instead so we need to account for that in the GIT config. But Git does
    # have a way to do this conditionally in the config files.
    export GIT_PAGER="batcat --pager=less"
fi
