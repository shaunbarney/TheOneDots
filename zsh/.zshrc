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

