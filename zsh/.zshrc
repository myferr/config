# GitHub
export CR_PAT= # container registry personal access token
export GITHUB_USER= # github username

# Go
export GOBIN=~/.local/bin/

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# sketchybar
export COLOR_SCHEME="catppuccin-mocha"

# Aliases
alias b='bun'
alias docker='echo "Use podman"' # trying my best to migrate from docker to podman
alias c='git commit -m'

# Environment paths
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"


# Preferred editor
export EDITOR="nvim"

# Bun completions
[ -s "/Users/$USER/.bun/_bun" ] && source "/Users/$USER/.bun/_bun"

# Starship init
eval "$(starship init zsh)"
