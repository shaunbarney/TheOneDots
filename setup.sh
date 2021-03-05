#!/bin/bash
 # echo "source $(pwd)/zsh/.zshrc" >> ~/.zshrc

sudo apt install -y nodejs npm tree git curl 

sudo npm install --global yarn

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
 
#mkdir -p ~/.config/nvim
#sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       #https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
#echo "source $(pwd)/nvim/init.vim" >> ~/.config/nvim/init.vim
#nvim +'PlugInstall --sync' +qa

#mkdir -p ~/.config/alacritty/
#cp ./alacritty/alacritty.yml  ~/.config/alacritty/alacritty.yml

#for f in $(ls -a ./tmux);
#do
        #if [[ $f == *".tmux"* ]]; then
            #cp ./tmux/$f ~/$f
        #fi
#done
