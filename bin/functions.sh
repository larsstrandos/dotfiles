# Shared functions for the scripts in bin/. Sourced, never executed.

dotfiles_dir="$(cd "${BASH_SOURCE[0]%/*}/.." && pwd)"
package_dir="$dotfiles_dir/home"
backup_root="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup}"

#
# Prints a log message.
#
function log()
{
	if [[ -t 1 ]]; then echo -e "\x1b[1m\x1b[32m>>>\x1b[0m \x1b[1m$1\x1b[0m"
	else                echo ">>> $1"
	fi
}

#
# Prints a warning message.
#
function warn()
{
	if [[ -t 2 ]]; then echo -e "\x1b[1m\x1b[33m***\x1b[0m \x1b[1m$1\x1b[0m" >&2
	else                echo "*** $1" >&2
	fi
}

#
# Prints an error message.
#
function error()
{
	if [[ -t 2 ]]; then echo -e "\x1b[1m\x1b[31m!!!\x1b[0m \x1b[1m$1\x1b[0m" >&2
	else                echo "!!! $1" >&2
	fi
}

#
# Prints an error message and exits.
#
function fail()
{
	error "$1"
	exit 1
}

#
# Lists every file in the stow package, relative to it.
#
function package_files()
{
	(cd "$package_dir" && find . -type f -printf '%P\n') || return $?
}

#
# Moves a path into the backup directory, keeping its place under $HOME.
#
function backup_path()
{
	local path="$1"
	local dest="$backup_dir/$path"

	mkdir -p "${dest%/*}"         || return $?
	mv "$HOME/$path" "$dest"      || return $?
	log "Backed up ~/$path"
}
