# Aliases
#alias v="nvim"
alias lv=lvim
alias v="/home/shaun/programs/nvim-linux64/bin/nvim"
alias siy="sudo apt install -y"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias tm="tmux"
alias t="tree . -I 'node_modules|venv'"
alias ra=ranger
alias gip="curl -o .gitignore https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore"
alias c="code "

alias sfa="per uvicorn app.main:app --reload"

alias sshpi="ssh root@192.168.1.102"

TREE_IGNORE="log|logs|node_modules|*.pyc|__pycache__"
alias l='exa -la --icons'
alias ls='exa -l --icons'
alias lr='exa -lRT -I ${TREE_IGNORE} --icons'

alias swagger="docker run --rm -it  --user $(id -u):$(id -g) -e GOPATH=$HOME/go:/go -v $HOME:$HOME -w $(pwd) quay.io/goswagger/swagger"

alias pes="pipenv shell"
alias pei="pipenv install"
alias peid="pipenv install --dev jedi mypy neovim autopep8 && pipenv shell"
alias pel="pipenv lock -r > requirements.txt"
alias per="clear && pipenv run"
alias peiapi="pipenv install fastapi uvicorn loguru --dev jedi mypy neovim autopep8 && pipenv shell"

alias awake="xset s off && xset -dpms"

alias tod="~/TheOneDots"

alias ti="touch __init__.py"

alias sp="sudo pacman "

alias dc="docker-compose"

alias copy="xclip -selection clipboard"

alias open="xdg-open"

alias vi3="nvim ~/.config/i3/config"
alias viz="nvim ~/TheOneDots/zsh/.zshrc"

alias whs="wormhole send"
alias whr="wormhole receive"

export PATH="$HOME/.cargo/bin:$PATH"
export VISUAL=vim
export EDITOR="$VISUAL"
export PATH=$PATH:/usr/local/go/bin

export PATH="$HOME/.pyenv/bin:$PATH"

# function cd {
#     builtin cd "$@"
#     if [ -f "Pipfile" ] ; then
#         pipenv shell
#     fi
#   }

function dickPic {
    echo "$1" >> dickPic.txt
    wormhole send dickPic.txt
    rm dickPic.txt
}


eval "$(pyenv init -)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
