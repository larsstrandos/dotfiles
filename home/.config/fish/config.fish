export TERM=xterm-256color

starship init fish | source

# ssh-agent runs as a systemd user service (ssh-agent.socket)
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

# always run in tmux
if status is-interactive
and not set -q TMUX
    exec tmux
end
