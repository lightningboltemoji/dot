PROMPT="%F{red}%n%f@%F{green}MBP %F{yellow}[%~] %F{blue}%% %f"
HISTSIZE=10000000
SAVEHIST=10000000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS

function desktop() {
  defaults write com.apple.finder CreateDesktop "$1" 
  killall Finder
}

function iconapply() {
  for f in $(ls $XDG_CONFIG_HOME/fileicon); do
    [ ! -d /Applications/${f%.*}.app ] || fileicon -q set /Applications/${f%.*}.app $XDG_CONFIG_HOME/fileicon/$f
  done
}

export PATH="$HOME/Developer/scripts:$PATH"
export GOPATH="$HOME/.go"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
