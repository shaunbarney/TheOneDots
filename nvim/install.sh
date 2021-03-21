#!/usr/bin/env bash
mkdir -p ~/.config/nvim/plugin
mkdir -p ~/.config/nvim/after/plugin
mkdir -p ~/.config/nvim/lua

for f in `find . -regex ".*\.vim$\|.*\.lua$"`; do
    echo Removing $f
    rm -rf ~/.config/nvim/$f
    echo Linking $f
    ln -s ~/TheOneDots/nvim/$f ~/.config/nvim/$f
done

