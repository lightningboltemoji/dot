PROMPT="%F{cyan}%n%f@%F{green}MBP %F{yellow}[%~] %F{blue}%% %f"
HISTSIZE=10000000
SAVEHIST=10000000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS

alias vi="nvim"
alias ve="source .venv/bin/activate"

function desktop() {
  defaults write com.apple.finder CreateDesktop "$1"
  killall Finder
}

export HOMEBREW_AUTO_UPDATE_SECS=3600
export PATH="$HOME/Developer/scripts:$PATH"
export GOPATH="$HOME/.go"

source <(fzf --zsh)
