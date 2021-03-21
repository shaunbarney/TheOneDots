#!/bin/bash
echo "source $(pwd)/zsh/.zshrc" >> ~/.zshrc

sudo apt install -y nodejs npm tree git curl gdebi-core

sudo npm install --global yarn

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
 
mkdir -p ~/.config/nvim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
echo "source $(pwd)/nvim/init.vim" >> ~/.config/nvim/init.vim
nvim +'PlugInstall --sync' +qa

mkdir -p ~/.config/alacritty/
cp ./alacritty/alacritty.yml  ~/.config/alacritty/alacritty.yml

for f in $(ls -a ./tmux);
do
        if [[ $f == *".tmux"* ]]; then
            cp ./tmux/$f ~/$f
        fi
done

sudo wget https://github.com/shiftkey/desktop/releases/download/release-2.1.0-linux1/GitHubDesktop-linux-2.1.0-linux1.deb
sudo gdebi GitHubDesktop-linux-2.1.0-linux1.deb

curl https://pyenv.run | zsh
