# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

export ZSH="/home/shaunb/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Aliases
alias v="nvim"
alias siy="sudo apt install -y"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias tm="tmux"
alias t="tree . -I 'node_modules|venv'"

alias pes="pipenv shell"
alias pei="pipenv install"
alias peid="pipenv install --dev jedi pylint neovim autopep8 && pipenv shell"
alias pel="pipenv lock -r > requirements.txt"
alias per="pipenv run"
alias peiapi="pipenv install fastapi uvicorn loguru"

alias ti="touch __init__.py"

alias sp="sudo pacman "

alias dc="sudo docker-compose"

alias copy="xclip -selection clipboard"

alias open="xdg-open"

alias vi3="nvim ~/.config/i3/config"
alias viz="nvim ~/Documents/TheOneDots/zsh/.zshrc"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.cargo/bin:$PATH"
export VISUAL=vim
export EDITOR="$VISUAL"
export PATH=$PATH:/usr/local/go/bin

export PATH="$HOME/.pyenv/bin:$PATH"

function cd {
    builtin cd "$@"
    if [ -f "Pipfile" ] ; then
        pipenv shell
    fi
  }

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/cuda/lib64"
export CUDA_HOME=/opt/cuda/

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
