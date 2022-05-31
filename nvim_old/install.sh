#!/usr/bin/env bash
mkdir -p ~/.config/nvim/plugin
mkdir -p ~/.config/nvim/after/plugin
mkdir -p ~/.config/nvim/lua
mkdir -p ~/.config/coc/ultisnips

RED='\033[0;31m'
GREEN='\033[0;32m'
for f in `find . -regex ".*\.vim$\|.*\.lua$"`; do
    printf "${RED}Removing ${f}\n"
    rm -rf ~/.config/nvim/$f
    printf "${GREEN}Linking ${f}\n"
    ln -s ~/TheOneDots/nvim/$f ~/.config/nvim/$f
done


cd ultisnips
for f in `find . -regex ".*\.snippets"`; do
    printf "${RED}Removing ${f}\n"
    rm -rf ~/.config/coc/ultisnips/$f
    printf "${GREEN}Linking ${f}\n"
    ln -s ~/TheOneDots/nvim/ultisnips/$f ~/.config/coc/ultisnips/$f
done
