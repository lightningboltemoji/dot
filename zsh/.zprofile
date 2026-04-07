if ! ssh-add -l &> /dev/null; then
    ssh-add
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
