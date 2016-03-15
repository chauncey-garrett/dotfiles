#!/usr/bin/env zsh
#
# Homebrew configuration
#

HOMEBREW_TAPS=(
    # caskroom/cask
    # caskroom/fonts
    # caskroom/versions
    homebrew/bundle
    homebrew/command-not-found
    homebrew/dupes
    homebrew/games
    homebrew/science
    homebrew/versions
)

HOMEBREW_FORMULAS=(
	# Required for gfortran
	gcc --with-all-languages
	# apple-gcc42 --with-gfortran-symlink

	pyenv
	rbenv

	#
	# Dependencies with options / Prioritized
	#

	# OpenSSL
	openssl

	# curl
	curl --with-c-ares --with-gssapi --with-libidn --with-libmetalink --with-libssh2 --with-nghttp2 --with-rtmpdump

	# wget
	wget --with-debug --with-gpgme --with-iri --with-libmetalink --with-pcre

	# SQLite
	sqlite --with-dbstat --with-docs --with-fts --with-functions --with-icu4c --with-json1 --with-unlock-notify

	# MySQL
	mysql

	# PostGreSQL
	postgresql --with-dtrace --with-python

	tcl-tk --enable-threads

	python --with-berkeley-db4 --with-tcl-tk --with-docs
	python3 --with-tcl-tk --with-docs
	ruby --with-doc --with-gdbm --with-gmp --with-libffi --with-suffix --with-tcltk
	lua --with-completion
	luajit --with-52compat --with-debug
	qt --with-d-bus --with-docs --with-mysql --with-postgresql --with-qt3support
	gtk --with-jasper --with-quartz-relocation
	swig
	# subversion --perl --ruby --with-python

	# Imagemagick
	ghostscript --with-djvu --with-x11
	librsvg --with-gtk+3 --with-libgsf
	libtiff --with-c++11
	little-cms --with-python
	webp --with-giflib --with-libtiff
	imagemagick --with-fftw --with-fontconfig --with-ghostscript --with-hdri --with-jp2 --with-liblqr --with-librsvg --withlibwmf --with-little-cms --with-little-cms2 --with-openexr --with-openmp --with-pango --with-perl --with-webp --with-x11

	# Graphicsmagick
	graphicsmagick --with-ghostscript --with-jasper --with-libwmf --with-little-cms2 --with-perl --with-webp --with-x11

	# GNU Plot
	# NOTE: If you use Aquaterm, it must be installed prior to building gnuplot!
	gnuplot --with-aquaterm --with-cairo --with-latex --with-pdflib-lite --with-qt --with-test --with-x11

	# Fonts
	# fontforge --with-extra-tools --with-giflib --with-libspiro

	# Git
	git --with-blk-sha1 --with-brewed-svn --with-gettext --with-pcre --with-persistent-https

	################################################################################

	#
	# Go
	#

	# go

	#
	# Ruby
	#

	ruby-build
	rbenv-aliases
	rbenv-bundler
	graphviz
	rbenv-binstubs
	rbenv-default-gems
	rbenv-whatis
	rbenv-vars
	rbenv-ctags

	#
	# Node
	#

	node

	#
	# Sass
	#

	libsass

	#
	# PostGreSQL
	#

	postgresql --enable-dtrace --with-python

	#
	# Python
	#

	pyenv-virtualenv
	pygtk --with-libglade
	py2cairo

	#
	# Perl
	#

	cpanminus

	#
	# R
	#

	# r

	#
	# Open Babel
	#

	# open-babel

	#
	# LaTeX
	#

	# automated compilation of documents
	# rubber

	#
	# Git
	#

	# upload to github gist
	gist

	# github like commit calendar
	git-cal

	# github issues
	ghi

	# human-workflows for git
	legit

	git-flow
	hub
	tig --with-docs
	# git-latexdiff

	#
	# Shells
	#

	# fish
	# fish

	# zsh
	zsh
	zsh-lovers

	# bash
	bash

	# mosh
	mobile-shell

	#
	# Xcode related
	#

	xctool

	#
	# GNU Utilities
	#

	# GNU privacy guard
	gnupg

	coreutils
	gnu-getopt
	gnu-sed
	gawk
	gnu-tar
	gnutls --with-guile --with-p11-kit
	dos2unix --with-gettext
	unix2dos --with-gettext
	findutils
	grep
	gnu-indent
	gnu-time
	gnu-units
	gnu-which

	#
	# Vim
	#

	vim --override-system-vi --with-lua --with-luajit --with-mzscheme --with-perl --with-tcl --with-client-server
	vimpager
	macvim --with-lua --with-luajit
	vifm
	ctags
	par

	#
	# Emacs
	#

	# emacs --cocoa --srgb --with-d-bus --with-gnutls --with-imagemagick --with-librsvg --with-x
	# auctex

	#
	# Nano
	#

	nano

	#
	# Utilities
	#

	# website load testing
	siege

	# bash/zsh linter
	shellcheck

	# sh portability linter
	checkbashisms

	lesspipe --syntax-highlighting

	# lorem genrator
	lorem

	# math on the commandline
	# mathomatic

	# fuzzy finder
	fzf

	# jq - parse JSON a la sed/awk
	jq

	# mtr - ping + traceroute
	mtr --with-glib --with-gtk+

	# show network usage
	iftop

	# environment module support
	modules --with-x11

	# more unix utilities
	# includes:
	#   - chronic
	#   - combine
	#   - errno
	#   - ifdata
	#   - ifne
	#   - isutf8
	#   - lckdo
	#   - mispipe
	#   - parallel
	#   - pee
	#   - sponge
	#   - ts
	#   - vidir
	#   - vipe
	#   - zrun
	moreutils

	# equivalent to GNU text-utils
	num-utils

	# PNG optimization
	optipng

	# monitor UNIX systems
	monit

	# (less, more,) most
	most

	# monitor multiple system logs, etc.
	multitail

	# UUID generation
	ossp-uuid

	# 7-Zip decompression
	p7zip

	# Brute-force decryption of PDF files
	pdfcrack

	# grep within PDF files
	pdfgrep

	# plots from FORTRAN and C
	# pgplot --with-button

	# parallelized gzip
	pigz

	# monitor pipes
	pipemeter

	# shell script syntax / bug checker
	roundup

	# rsync # use Bombich's rsync instead - http://bombich.com/kb/ccc4/credits
	rsync
	autossh
	unrar
	tmpwatch

	# pipeviewer
	pv

	# view process heirarchy
	pstree

	# histogram graphs
	distribution

	# record shell sessions
	asciinema

	# sparklines for your shell
	spark

	# fuzzy text selector for files
	selecta

	# directory hierarchy
	tree

	# truncate files
	truncate

	# insert a line rule in the terminal window for reference
	hr

	# align columns
	align

	# search
	ack
	the_silver_searcher

	# set the environment based on the directory
	autoenv

	fasd
	figlet
	midnight-commander

  # ncurses based file navigation
	ranger

  # for video previews in ranger
  # https://github.com/hut/ranger/wiki/Video-Previews
  w3m
  ffmpegthumbnailer

	# a random thought for the day
	fortune
	# fortune --no-offensive

	# cluster ssh control
	csshx

	# reformat/change dates
	dateutils

	# filesystem usage
	dfc

	# file renaming utilities
	renameutils
	rename

	#
	# Database utilities
	#

	kyoto-cabinet

	#
	# Internet
	#

	# web page archiving via PNG
	webkit2png

	# DNS speedup
	namebench

	# Pandora
	pianobar

	# YouTube
	# youtube-dl
	mplayer --with-libcaca

	# Speedtest
	speedtest_cli

	# netcat
	netcat

	# #
	# # OS X
	# #

	# # use Trash instead of rm
	# trash

	# # bluetooth toggling
	# blueutil

	# # terminal notifications
	# terminal-notifier

	# # 1Password
	# onepass

	# htop
	htop

	# # wifi-password
	# wifi-password

	# # Calendar
	# ical-buddy

	# # web location thumbnails
	# setweblocthumb

	# # change the audio source
	# switchaudio-osx

	# # set the screen brightness
	# screenbrightness

	# # set the screen resolution
	# screenresolution

	# # OS X preference files back
	# # mackup

	# # unarchiver cli
	# unar

	# # manipulate tags
	# tag

	# # manage the Dock
	# dockutil

	#
	# Wine
	#

	# wine --with-libgsm
	# winetricks

	#
	# Writing
	#

	jrnl
	multimarkdown
	pandoc

	#
	# Coding
	#

	task

	# POSIX compatibility check for bash scripts
	checkbashisms

	#
	# Photography
	#

	exiftool

	#
	# TMUX
	#

	tmux
	reattach-to-user-namespace --with-wrap-launchctl --with-wrap-pbcopy-and-pbpaste

	#
	# Fun
	#

	# cheesy print for messaging
	cowsay
	ponysay

	# analogue clock
	clockywock

	# Matrix screensaver
	cmatrix

	#
	# Games
	#

	# adventure quest game
	nethack

	# Space Invaders
	ninvaders

	# Chess
	gnu-chess

	# mindless search game
	robotfindskitten

	# Tetris
	vitetris

	# MasterMind type game and puzzle-solver
	color-code

	# anagrams
	wordplay

	#
	# Document conversion and formatting
	#

	# PNG -> ico
	png2ico

	# make icns files
	makeicns

	# <= 2003 Word -> Plain TXT and PostScript
	antiword

	# extract Word text
	# also includes xls2csv to convert Excel to csv format
	# catdoc

	# PDF -> HTML
	pdf2htmlex

	# PDF -> image
	# pdf2image

	# HTML tidy
	tidy-html5

	# Gif manipulation
	gifsicle --with-x11

	# RTF -> LaTeX2e
	rtf2latex2e

	# LaTeX -> RTF
	latex2rtf

	# HTML -> txt
	html2text

	#
	# Colorize
	#

	colordiff
	colormake
	colorsvn
	colortail
	source-highlight
	icdiff
	diff-so-fancy
  wdiff

	################################################################################
	# dnsmasq
	# phantomjs
	# gh
	# nginx
	# mysql
	# sitespeedio
	# todo-txt
	# gdal #1.11.1
	# geos #3.4.2
	# postgis #2.1.4
	# proj #4.8.0
	# libmemcached #1.0.18
	# redis
	# aacgain
	# grc
	# libnet
	# ncdu
	# nmap
	# pkg-config
	# vnstat
	# alpine
	# asciidoc
	# autoconf
	# automake
	# boost
	# cdrdao
	# cmake
	# cups-pdf
	# djvu2pdf
	# djvulibre
	# docbook
	# faac
	# faad2
	# fdupes
	# ffmpeg
	# flac
	# fontconfig
	# freetype
	# gd
	# gettext
	# ghc
	# glances
	# glew
	# glib
	# gmp
	# haskell-platform
	# iperf
	# jasper
	# jbig2dec
	# jpeg
	# json-c
	# lame
	# libao
	# libdvdcss
	# libevent
	# libffi
	# libgcrypt
	# libgpg-error
	# libmpc
	# libmrss
	# libnxml
	# libogg
	# libpng
	# librsync
	# libtasn1
	# libtool
	# libvorbis
	# libyaml
	# little-cms2
	# lrzsz
	# mad
	# mpfr
	# mutt
	# nettle
	# oniguruma
	# openjpeg
	# p11-kit
	# pmw
	# poppler
	# pos
	# pow
	# protobuf
	# readline
	# rmtrash
	# rsstail
	# s-lang
	# scons
	# texi2html
	# tokyo-cabinet
	# wordnet
	# x264
	# xvid
	# xz
	# yasm
	# zsh-completions
	# zssh
	)

	HOMEBREW_CASKS=(
		# fonts
	#     font-inconsolata-dz-for-powerline
	#     font-inconsolata
	#     font-source-code-pro
	#     font-droid-sans-mono
	#     font-meslo-lg

		# QuickLook Plugins
	#     qlcolorcode
	#     qlmarkdown
	#     qlprettypatch
	#     qlstephen
	#     quicklook-csv
	#     quicklook-json
	#     webp-quicklook

		# Apps
	#     google-chrome
	#     firefox
	#     caffeine
	#     alfred
	#     spectacle
	#     imagealpha
	#     imageoptim
	#     iterm2
	#     sequel-pro
	#     the-unarchiver
	#     sketch
	#     skype
	#     wunderlist
	#     lime-chat
	#     transmit
	#     vlc
	#     hipchat
	#     betterzipql
	#     recordit
	#     appcleaner
	#     virtualbox
	#     vagrant
	#     vagrant-manager
)

#
# Install packages
#

# Exit if no brew command
(( ! $+commands[brew] )) && echo "You need to install homebrew first!" && exit 1

# Upgrade to the latest and greatest
echo "updating"
brew update

echo "upgrading"
brew upgrade

# Ensure clean environment
echo "pruning"
brew prune

echo "cleaning"
brew cleanup

# Install packages
taps() {
	echo "tapping"

	for tap in "${HOMEBREW_TAPS[@]}"; do
		brew tap "${tap}"
	done
}

taps

formulas() {
	echo "installing"

	for formula in "${HOMEBREW_FORMULAS[@]}"; do
		brew install "${formula}"
	done
}

formulas

# Install apps
apps() {
	echo "installing apps"

	for app in "${HOMEBREW_CASKS[@]}"; do
		brew cask "${app}"
	done

	brew cask alfred link
}

apps

# Check for errors
echo "doctoring"
brew doctor

# Finalize
echo "finalizing"
brew cleanup

echo "linking apps"
brew linkapps

