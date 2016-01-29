#!/usr/bin/env zsh
#
# Homebrew configuration
#

HOMEBREW_TAPS=(
    homebrew/dupes
    homebrew/games
    homebrew/science
    homebrew/versions
    caskroom/cask
    caskroom/fonts
    caskroom/versions
)

HOMEBREW_FORMULAS=(
	pyenv
	rbenv

	#
	# Dependencies with options / Prioritized
	#

	# OpenSSL
	openssl

	tcl-tk --enable-threads

	python --with-brewed-tk --with-docs
	python3 --with-brewed-tk --with-docs
	ruby --with-doc --with-gdbm --with-gmp --with-libffi --with-suffix --with-tcltk
	lua --with-completion
	luajit --enable-debug
	qt --with-d-bus --with-docs --with-mysql
	gtk --with-jasper
	swig
	subversion --perl --ruby --with-python

	# Imagemagick
	ghostscript --with-djvu --with-x11
	librsvg --with-libgsf
	libtiff --with-c++11
	little-cms --with-python
	webp --with-giflib
	imagemagick --with-fontconfig --with-jp2 --with-liblqr --with-librsvg --with-libtiff --withlibwmf --with-little-cms2 --with-little-cms2 --with-openexr --with-perl --with-webp --with-x11

	# Graphicsmagick
	graphicsmagick --with-ghostscript --with-jasper --with-libtiff --with-libwmf --with-little-cms --with-little-cms2 --with-perl --with-x11

	# GNU Plot
	# NOTE: If you use Aquaterm, it must be installed prior to building gnuplot!
	gnuplot --cairo --latex --pdf --qt --tests --with-x --wx

	# Fonts
	fontforge --with-cairo --with-czmq --with-gif --with-libspiro --with-pango --with-python --with-x

	################################################################################

	#
	# Go
	#

	go

	#
	# Ruby
	#

	ruby-build
	rbenv-aliases
	rbenv-bundler
	graphviz
	rbenv-binstubs
	rbenv-default-gems
	rbenv-gem-rehash
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

	pyenv-pip-rehash
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

	r

	#
	# Open Babel
	#

	open-babel --with-cairo --with-python --with-wxmac

	#
	# LaTeX
	#

	# automated compilation of documents
	rubber

	#
	# Git
	#

	# git itself
	git --with-blk-sha1 --with-brewed-curl --with-brewedopenssl --with-brewed-svn --with-gettext --with-pcre --with-persistent-https

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
	git-latexdiff

	#
	# Shells
	#

	# fish
	fish

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

	# required for gfortran
	gcc --with-all-languages --with-profiled-build
	# apple-gcc42 --with-gfortran-symlink

	# GNU privacy guard
	gnupg --8192

	coreutils
	gnu-getopt
	gnu-sed
	gawk
	gnu-tar
	gnutls --with-guile --with-p11-kit
	dos2unix
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

	emacs --cocoa --srgb --with-d-bus --with-gnutls --with-imagemagick --with-librsvg --with-x
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
	mathomatic

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
	pgplot --with-button

	# parallelized gzip
	pigz

	# monitor pipes
	pipemeter

	# shell script syntax / bug checker
	roundup

	# rsync # use Bombich's rsync instead - http://bombich.com/kb/ccc4/credits
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
	ranger

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

	# curl
	curl --with-ares --with-gssapi --with-idn --with-libmetalink --with-rtmp --with-ssh

	# wget
	wget --enable-debug --enable-iri

	# YouTube
	# youtube-dl
	mplayer --with-libcaca --with-x11

	# Speedtest
	speedtest_cli

	# netcat
	netcat

	#
	# OS X
	#

	# use Trash instead of rm
	trash

	# bluetooth toggling
	blueutil

	# terminal notifications
	terminal-notifier

	# 1Password
	onepass

	# htop
	htop-osx

	# wifi-password
	wifi-password

	# Calendar
	ical-buddy

	# web location thumbnails
	setweblocthumb

	# change the audio source
	switchaudio-osx

	# set the screen brightness
	screenbrightness

	# set the screen resolution
	screenresolution

	# OS X preference files back
	# mackup

	# unarchiver cli
	unar

	# manipulate tags
	tag

	# manage the Dock
	dockutil

	#
	# Wine
	#

	wine --with-libgsm
	winetricks

	#
	# Web development
	#

	#
	# Writing
	#

	jrnl
	multimarkdown
	pandoc

	#
	# Coding
	#

	task --with-gnutls

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
	reattach-to-user-namespace --wrap-launchctl --wrap-pbcopy-and-pbpaste

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
	# gdbm
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
echo "installing apps"
brew cask "${HOMEBREW_CASKS[@]}"

brew cask alfred link

# Check for errors
echo "doctoring"
brew doctor

# Finalize
echo "finalizing"
brew cleanup

echo "linking apps"
brew linkapps
