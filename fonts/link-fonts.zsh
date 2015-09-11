#!/usr/bin/env zsh
#
# This script will symlink all the fonts found in external to the current directory for export later on via the Rakefile.
#


function symlink-fonts()
{
	cd ${DOTFILES:-$HOME}/.dotfiles/fonts

	for font in external/**/{*.otf,*.ttf}
	do
		/bin/ln -s $font
	done
}

symlink-fonts
