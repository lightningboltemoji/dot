export SSH_AUTH_SOCK=`ls /private/tmp/com.apple.launchd.*/Listeners`
if ! ssh-add -l &> /dev/null; then
    ssh-add
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
