if [ ! -f "$SSH_AUTH_SOCK" ] && [ -f "$XDG_RUNTIME_DIR/ssh-agent.env" ]; then
    if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
    fi
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi
if ! ssh-add -l &> /dev/null; then
    ssh-add
fi

