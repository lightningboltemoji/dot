ssh-add -l >/dev/null 2>&1
if (( $? == 2 )); then
    _agent_sock=${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/ssh-agent.sock
    SSH_AUTH_SOCK=$_agent_sock ssh-add -l >/dev/null 2>&1
    if (( $? == 2 )); then
        rm -f $_agent_sock
        ssh-agent -a $_agent_sock >/dev/null 2>&1
    fi
    export SSH_AUTH_SOCK=$_agent_sock
    unset _agent_sock
fi
