require 'rake'
require 'fileutils'

task :default => 'install:default'

#
# Install scripts...
#

namespace :install do

	desc "Install node_modules"
	task :node_modules do
  		if want_to_install?('node_modules')
			message_installing("node_modules")
			install_node_modules
			message_installed("node_modules")
		end
	end

	desc "Install dotfiles"
	task :dotfiles do
  		if want_to_install?('dotfiles')
			message_installing("dotfiles")
			install_dotfiles
			message_installed("dotfiles")
		end
	end

	desc "Setup rbenv (for Ubuntu server, otherwise use Homebrew)"
	task :rbenv do
  		if want_to_install?('rbenv')
			message_installing("rbenv")
			install_rbenv if RUBY_PLATFORM.downcase.include?("linux")
			message_installed("rbenv")
		end
	end

	desc "Install Homebrew (OS X Package Manager)"
	task :homebrew do
  		if want_to_install?('Homebrew (OS X Package Manager)')
			message_installing("homebrew")
			install_homebrew if RUBY_PLATFORM.downcase.include?("darwin")
			message_installed("homebrew")
		end
	end

	desc "Install QuickLook Plugins (OS X only)"
	task :osx_quicklook_plugins do
  		if want_to_install?('QuickLook Plugins')
			message_installing("QuickLook Plugins")
			install_osx_quicklook_plugins if RUBY_PLATFORM.downcase.include?("darwin")
			message_installed("QuickLook Plugins")
		end
	end

	desc "Install coding osx_fonts (OS X only)"
	task :osx_fonts do
  		if want_to_install?('Coding fonts for OS X')
			message_installing("osx_fonts")
			install_osx_fonts if RUBY_PLATFORM.downcase.include?("darwin")
			message_installed("osx_fonts")
		end
	end

	desc "Install saved searches (OS X only)"
	task :osx_saved_searches do
  		if want_to_install?('OS X Saved Searches')
			message_installing("OS X Saved Searches")
			install_osx_saved_searches if RUBY_PLATFORM.downcase.include?("darwin")
			message_installed("OS X Saved Searches")
		end
	end

	desc "Install keybindings (OS X only)"
	task :osx_keybindings do
  		if want_to_install?('Keybindings for OS X')
			message_installing("OS X Keybindings")
			install_osx_keybindings if RUBY_PLATFORM.downcase.include?("darwin")
			message_installed("OS X Keybindings")
		end
	end

	desc "Install Services (OS X only)"
	task :osx_services do
  		if want_to_install?('Services for OS X')
			message_installing("Services")
			install_osx_services if RUBY_PLATFORM.downcase.include?("darwin")
			message_installed("Services")
		end
	end

	desc "Install LaunchAgents (OS X only)"
	task :osx_launch_agents do
  		if want_to_install?('LaunchAgents for OS X')
			message_installing("LaunchAgents")
			install_osx_launch_agents if RUBY_PLATFORM.downcase.include?("darwin")
			message_installed("LaunchAgents")
		end
	end

	desc "Install iTerm2 solarized theme (OS X only)"
	task :term_theme do
  		if want_to_install?('iTerm2 solarized theme for OS X')
			message_installing("iTerm2 solarized theme")
		    install_iterm2_theme_solarized if RUBY_PLATFORM.downcase.include?("darwin")
			message_installed("iTerm2 solarized theme")
		end
	end

	desc "Install tern (Vim plugin)"
	task :vim_tern do
  		if want_to_install?('tern (Vim plugin)')
			message_installing("tern")
			install_tern
			message_installed("tern")
		end
	end

	desc "Install Janus (Vim distribution)"
	task :janus do
  		if want_to_install?('Janus (Vim distribution)')
			message_installing("janus")
			install_janus
			message_installed("janus")
		end
	end

	desc "Install default configuration! (dotfiles, Homebrew, Janus, fonts, iTerm2 solarized theme)"
	task :default => [	:dotfiles,
						:homebrew,
						:janus,
						:osx_fonts,
						:term_theme ] do
		message_installed("defaults")
	end

	desc "Install everything!"
	task :all => [	:dotfiles,
					:homebrew,
					:janus,
					:osx_fonts,
					:osx_launch_agents,
					:osx_services,
					:osx_keybindings,
					:osx_saved_searches,
					:osx_quicklook_plugins,
					:term_theme ] do
		message_installed("everything")
	end

	# message_final("successful")
end

#
# Update scripts...
#

namespace :update do

	desc "Update dotfiles"
	task :dotfiles do
  		if want_to_install?('dotfiles')
			message_updating("dotfiles")
			update_dotfiles
			message_updated("dotfiles")
		end
	end

	desc "Update Homebrew package manager"
	task :homebrew do
		if want_to_install?('homebrew')
			message_updating("homebrew")
			update_homebrew
			message_updated("homebrew")
		end
	end

	desc "Update all installed!"
	task :all => [	:dotfiles,
					:homebrew,
					:janus,
					:osx_fonts,
					:term_theme ] do
		message_updated("all")
	end

	# message_final("successful")
end

#
# Definitions...
#

private

def run(cmd)
	puts "[Running] #{cmd}"
	`#{cmd}` unless ENV['DEBUG']
end

def want_to_install? (section)
	if ENV["ASK"]=="true"
		puts "Install:  #{section}? [Y]es | [n]o"
		STDIN.gets.chomp == 'Y'
	else
		true
	end
end

def install_osx_fonts
    run %{ $HOME/.dotfiles/fonts/link-fonts.zsh }
	run %{ cp -f $HOME/.dotfiles/fonts/{*.otf,*.ttf} $HOME/Library/Fonts/ }
	run %{ chmod 644 $HOME/Library/Fonts/* }
end

def install_osx_quicklook_plugins
	run %{ cp -RL -f $HOME/.dotfiles/osx-quicklook-plugins/*qlgenerator $HOME/Library/QuickLook/ }
	run %{ cp -f $HOME/.dotfiles/osx-quicklook-plugins/*css $HOME }
	run %{ qlmanage -r }
end

def install_osx_keybindings
	run %{ mkdir -p $HOME/Library/KeyBindings }
	run %{ cp -f $HOME/.dotfiles/keybindings/DefaultKeyBinding.dict $HOME/Library/KeyBindings/ }
	run %{ defaults write -g NSRepeatCountBinding -string "^u" }
end

def install_osx_saved_searches
	run %{ mkdir -p "$HOME/Library/Saved Searches" }
	run %{ cp -f $HOME/.dotfiles/osx-saved-searches/* "$HOME/Library/Saved Searches" }
end

def install_osx_services
	run %{ mkdir -p $HOME/Library/Services }
	run %{ cp -R -f $HOME/.dotfiles/osx-services/* $HOME/Library/Services/ }
end

def install_osx_launch_agents
	run %{ mkdir -p $HOME/Library/LaunchAgents }
	run %{ cp -f $HOME/.dotfiles/osx-launch-agents/* $HOME/Library/LaunchAgents/ }
end

def install_iterm2_theme_solarized
	run %{ /usr/libexec/PlistBuddy -c "Add :'Custom Color Presets':'Solarized Light' dict" ~/Library/Preferences/com.googlecode.iterm2.plist }
	run %{ /usr/libexec/PlistBuddy -c "Merge 'iTerm2/Solarized Light.itermcolors' :'Custom Color Presets':'Solarized Light'" ~/Library/Preferences/com.googlecode.iterm2.plist }
	run %{ /usr/libexec/PlistBuddy -c "Add :'Custom Color Presets':'Solarized Dark' dict" ~/Library/Preferences/com.googlecode.iterm2.plist }
	run %{ /usr/libexec/PlistBuddy -c "Merge 'iTerm2/Solarized Dark.itermcolors' :'Custom Color Presets':'Solarized Dark'" ~/Library/Preferences/com.googlecode.iterm2.plist }

	# If iTerm2 is not installed or has never run, we can't autoinstall the profile since the plist is not there
	if !File.exists?(File.join(ENV['HOME'], '/Library/Preferences/com.googlecode.iterm2.plist'))
		puts
		puts "To ensure your profile is using the solarized theme, please check your settings under:"
		puts "	Preferences > Profiles > [your profile] > Colors > Load Preset..."
		puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
		return
	end

	# Ask the user which theme he wants to install
	message = "Which theme would you like to apply to your iTerm2 profile?"
	color_scheme = ask message, iTerm_available_themes
	color_scheme_file = File.join('iTerm2', "#{color_scheme}.itermcolors")

	# Ask the user on which profile he wants to install the theme
	profiles = iTerm_profile_list
	message = "I've found #{profiles.size} #{profiles.size>1 ? 'profiles': 'profile'} on your iTerm2 configuration, which one would you like to apply the Solarized theme to?"
	profiles << 'All'
	selected = ask message, profiles

	if selected == 'All'
		(profiles.size-1).times { |idx| apply_theme_to_iterm_profile_idx idx, color_scheme_file }
	else
		apply_theme_to_iterm_profile_idx profiles.index(selected), color_scheme_file
	end
end

def iTerm_available_themes
	Dir['iTerm2/*.itermcolors'].map { |value| File.basename(value, '.itermcolors')}
end

def iTerm_profile_list
	profiles=Array.new
	begin
		profiles <<  %x{ /usr/libexec/PlistBuddy -c "Print :'New Bookmarks':#{profiles.size}:Name" ~/Library/Preferences/com.googlecode.iterm2.plist 2>/dev/null}
	end while $?.exitstatus==0
	profiles.pop
	profiles
end

def apply_theme_to_iterm_profile_idx(index, color_scheme_path)
  values = Array.new
  16.times { |i| values << "Ansi #{i} Color" }
  values << ['Background Color', 'Bold Color', 'Cursor Color', 'Cursor Text Color', 'Foreground Color', 'Selected Text Color', 'Selection Color']
  values.flatten.each { |entry| run %{ /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':#{index}:'#{entry}'" ~/Library/Preferences/com.googlecode.iterm2.plist } }

  run %{ /usr/libexec/PlistBuddy -c "Merge '#{color_scheme_path}' :'New Bookmarks':#{index}" ~/Library/Preferences/com.googlecode.iterm2.plist }
end

def ask(message, values)
  puts message
  while true
    values.each_with_index { |val, idx| puts " #{idx+1}. #{val}" }
    selection = STDIN.gets.chomp
    if (Float(selection)==nil rescue true) || selection.to_i < 0 || selection.to_i > values.size+1
      puts "ERROR: Invalid selection."
	  puts
	  puts
    else
      break
    end
  end
  selection = selection.to_i-1
  values[selection]
end

def install_rbenv
	run %{ which ruby }
	unless $?.success?
		run %{ sudo apt-get install ruby }
	end

	run %{ which git }
	unless $?.success?
		run %{ sudo apt-get install git }
	end

    run %{ which rbenv }
	unless $?.success?
		run %{ sudo apt-get install rbenv }
		run %{ gem install bundler }
		run %{ git clone -- https://github.com/tpope/rbenv-aliases.git ~/.rbenv/plugins/rbenv-aliases }
        run %{ git clone -- https://github.com/ianheggie/rbenv-binstubs.git ~/.rbenv/plugins/rbenv-binstubs }
		run %{ git clone -- https://github.com/carsomyr/rbenv-bundler.git ~/.rbenv/plugins/bundler }
		run %{ git clone -- https://github.com/tpope/rbenv-ctags.git ~/.rbenv/plugins/rbenv-ctags }
		run %{ git clone -- https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash }
	end
end

def install_homebrew
	run %{ which brew }
	unless $?.success?
		run %{ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" }
	end

    run %{ sh Brewfile.sh }
end

def update_homebrew
	run %{ which brew }
	unless $?.success?
		install_homebrew
	end

	run %{ brew prune }
	run %{ brew cleanup }
	run %{ brew update }
	run %{ brew tap --repair }
	run %{ brew doctor }
	run %{ brew outdated }
end

def install_tern
  run %{ cd "$HOME/.dotfiles/janus/tern" && npm install }
end

def install_janus
	puts "Janus requires Vim >= 7.3, ack, ctags, git, ruby and rake."
	run %{ curl -Lo- https://bit.ly/janus-bootstrap | bash }
end

def install_node_modules
  node_modules = [
    'browser-sync',
    'csslint',
    'docco',
    'jsctags',
    'jshint',
    'tern',
    'tldr'
  ]

  node_modules.each do |node_module|
    puts "Installing npm node_module: #{node_module}."
    run %{ sudo npm install -g #{node_module} }
  end
end

def install_dotfiles
	run %{ $HOME/.dotfiles/bin/dotsync -L }
end

def make_zsh_default_shell
	if ENV["SHELL"].include? 'zsh' then
	# if ENV["SHELL"] =~ /zsh/
		puts "Already using Zsh..."
	else
		print "Make Zsh default? (recommended) [Ynq]"
		puts
		case $stdin.gets.chomp
			when 'Y'
				puts "Switching to Zsh..."
				run %{ chsh -s /bin/zsh }
			when 'q'
				puts "Exiting..."
				exit
			else
				puts "Zsh will NOT be the default shell..."
		end
	end
end

def message_installing(action)
	puts
	puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	puts "Installing #{action}..."
	puts
end

def message_installed(action)
	puts
	puts "Installed #{action}."
	puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	puts
end

def message_updating(action)
	puts
	puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	puts "Updating #{action}..."
	puts
end

def message_updated(action)
	puts
	puts "Updated #{action}."
	puts "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	puts
end

def message_final(action)
	puts "Your configuration was #{action}. Restart your terminal for cake."
end

