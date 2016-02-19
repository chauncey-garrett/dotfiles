#!/usr/bin/env zsh
#
# Generate git ignore files from Github's master gitignore repo
#
# See https://github.com/github/gitignore for more info.
#

#
# Constants
#

script_dir="${0:a:h}"
repo_dir="${script_dir}/external/gitignore"
languages_dir="${repo_dir}"
globals_dir="${repo_dir}/Global"
tmp_file="${TMPDIR:-/tmp}/gitignore.tmp"
destination="${script_dir}/gitignore"

globals=(
  Archives
  GPG
  Linux
  MicrosoftOffice
  OSX
  SVN
  Tags
  TextMate
  Vagrant
  Vim
)

languages=(
  # Ruby
)

#
# Functions
#

function add-globals() {
  for file in "${globals[@]}"; do
    segregate-section-by-name "${file}"
    cat "${globals_dir}/${file}.gitignore" >> "${tmp_file}"
  done
}

function add-languages() {
  for file in "${languages[@]}"; do
    segregate-section-by-name "${file}"
    cat "${languages_dir}/${file}.gitignore" >> "${tmp_file}"
  done
}

function segregate-section-by-name() {
cat <<-EOF >> "${tmp_file}"

#
# ${1}
#

EOF
}

function clean() {

  # Choose your options for cleaning:

  # Remove comments
  # gsed -i '/^[[:blank:]]*#/d' "${tmp_file}"

  # Sort
  # sort "${tmp_file}" > "${destination}"

  # Remove empty lines
  # gsed -i '/^[[:blank:]]*$/d' "${tmp_file}"

  # Remove duplicate, subsequent lines
  uniq "${tmp_file}" > "${destination}"

  # Remove all duplicate lines
  # sort "${tmp_file}" | uniq > "${destination}"
}

#
# Main
#

function main() {
  touch "${destination}"
  rm "${tmp_file}"

  add-globals
  add-languages
  clean
}

main "$@"

