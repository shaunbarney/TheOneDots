# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/home/shaun/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh
source /home/shaun/.oh-my-zsh/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh

# Aliases
alias v="nvim"
alias siy="sudo apt install -y"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias t="tree . -I 'node_modules|venv'"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.cargo/bin:$PATH"
export VISUAL=vim
export EDITOR="$VISUAL"

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
