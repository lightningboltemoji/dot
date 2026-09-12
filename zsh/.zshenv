if [[ -n $SSH_CONNECTION ]]; then
    _agent_link=$HOME/.ssh/agent.sock
    if [[ -S $SSH_AUTH_SOCK && $SSH_AUTH_SOCK != $_agent_link ]]; then
        ssh-add -l >/dev/null 2>&1
        (( $? != 2 )) && ln -sf $SSH_AUTH_SOCK $_agent_link
    fi
    [[ -S $_agent_link ]] && export SSH_AUTH_SOCK=$_agent_link
    unset _agent_link
fi
