#!/usr/bin/env bash

pip3 install --upgrade pip

pip3 install \
  --upgrade \
  --user \
  --break-system-packages \
  --requirement ~/.dotfiles/requirements3.txt
