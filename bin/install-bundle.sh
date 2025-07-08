#!/usr/bin/env bash

bundle install \
  --path ~/.gem \
  --gemfile=~/.dotfiles/Gemfile \

bundle update \
  --path ~/.gem \
  --gemfile=~/.dotfiles/Gemfile \
