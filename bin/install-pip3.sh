#!/usr/bin/env zsh

pip3 install --upgrade pip

pip3 install \
  --upgrade \
  --user \
  --break-system-packages \
  --requirement ~/.dotfiles/requirements3.txt
