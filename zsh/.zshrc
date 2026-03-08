# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

# Arch flexing
fastfetch

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100
SAVEHIST=100
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/byte/.zshrc'

autoload -Uz compinit
compinit

# Oh my posh
eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/omp.toml)"

# Alias
alias ff="clear; fastfetch"
alias ls="eza --icons"
alias yazi="sudo yazi"
alias ga="git add ."
alias gp="git push"
alias c="clear"
alias font="fc-cache -fr"
alias cmatrix="cmatrix -u 10 -B f"
alias g="glow"
alias vi="vim"
alias tree="tree -ah -I '.git'"
alias yeet='paru -Rcs'
alias yay='paru'
alias top='btop'
alias htop='btop'
alias omp='oh-my-posh'
alias ompexj='oh-my-posh config export -f json -o ~/.dotfiles/zsh/.config/ohmyposh/omp.json'
alias ompext='oh-my-posh config export -f toml -o ~/.dotfiles/zsh/.config/ohmyposh/omp.toml'
alias reload='source ~/.zshrc'
alias tree='eza -T --icons'

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export TERMINAL=/usr/bin/kitty
export TERM=xterm-256color
export EDITOR=vim
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --border=none \
  --color=bg+:#2e3c64 \
  --color=bg:#1f2335 \
  --color=border:#29a4bd \
  --color=fg:#c0caf5 \
  --color=gutter:#1f2335 \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#29a4bd \
  --color=separator:#ff9e64 \
  --color=spinner:#ff007c \
"

# Zoxide

compinit
eval "$(zoxide init zsh --cmd cd)"

# Uncomment this if using homeberw
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
