#!/usr/bin/env bash

for file in ~/.dotfiles/tmux/*.terminfo; do
  tic $file;
done
