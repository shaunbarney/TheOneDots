#!/usr/bin/env bash
mkdir -p ~/.config/nvim/plugin
mkdir -p ~/.config/nvim/after/plugin
mkdir -p ~/.config/nvim/lua

RED='\033[0;31m'
GREEN='\033[0;32m'
for f in `find . -regex ".*\.vim$\|.*\.lua$"`; do
    printf "${RED}Removing ${f}\n"
    rm -rf ~/.config/nvim/$f
    printf "${GREEN}Linking ${f}\n"
    ln -s ~/TheOneDots/nvim/$f ~/.config/nvim/$f
done


