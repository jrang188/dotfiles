# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  fnm
  bun
  helm
  kubectl
  aws
  keychain
  docker
  docker-compose
)

# Detect OS and add platform-specific plugins
if [[ "$(uname)" == "Linux" ]]; then
  plugins+=(ubuntu)
elif [[ "$(uname)" == "Darwin" ]]; then
  plugins+=(macos brew)
fi

source $ZSH/oh-my-zsh.sh

## User configuration

# neovim
alias vim="nvim"

#oh my posh
eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json)"
