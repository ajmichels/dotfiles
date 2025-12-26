if [[ ! -f /etc/os-release ]]; then
    exit 0
fi

source /etc/os-release
if [[ "$ID" != "debian" ]] && [[ "$ID_LIKE" != *"debian"* ]]; then
    exit 0
fi

alias bat=batcat
