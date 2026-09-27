#!/usr/bin/env bash
# Install this Neovim config on a fresh Linux machine.
#
#   git clone <repo-url> ~/.config/nvim && ~/.config/nvim/install.sh
#
# Options:
#   --no-deps   skip system packages (only link config + install plugins)
#   --no-sudo   never call sudo; user-local binaries only
set -euo pipefail

NVIM_MIN="0.11.0"
LOCAL_BIN="$HOME/.local/bin"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

WITH_DEPS=1
USE_SUDO=1
for arg in "$@"; do
	case "$arg" in
	--no-deps) WITH_DEPS=0 ;;
	--no-sudo) USE_SUDO=0 ;;
	-h | --help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
	*) echo "unknown option: $arg" >&2; exit 1 ;;
	esac
done

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }
sudo_() { if [ "$(id -u)" -eq 0 ]; then "$@"; elif [ "$USE_SUDO" -eq 1 ] && have sudo; then sudo "$@"; else return 1; fi; }

# version_ge A B -> true if A >= B
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }

case "$(uname -m)" in
x86_64 | amd64) NVIM_ARCH="x86_64"; TS_ARCH="x64" ;;
aarch64 | arm64) NVIM_ARCH="arm64"; TS_ARCH="arm64" ;;
*) NVIM_ARCH=""; TS_ARCH="" ;;
esac

install_packages() {
	# git/curl/unzip/tar: plugin + mason downloads; gcc/make: treesitter/telescope builds
	# ripgrep/fd: telescope; node/npm: ts_ls, eslint, prettier, bashls; python3: pylsp
	if have dnf; then
		sudo_ dnf install -y git curl unzip tar gzip gcc gcc-c++ make ripgrep fd-find \
			nodejs npm python3 python3-pip ImageMagick xclip wl-clipboard
	elif have apt-get; then
		sudo_ apt-get update
		sudo_ apt-get install -y git curl unzip tar gzip build-essential ripgrep fd-find \
			nodejs npm python3 python3-pip python3-venv imagemagick xclip wl-clipboard
		# Debian/Ubuntu ship fd as `fdfind`
		if have fdfind && ! have fd; then mkdir -p "$LOCAL_BIN"; ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"; fi
	elif have pacman; then
		sudo_ pacman -Sy --needed --noconfirm git curl unzip tar gzip base-devel ripgrep fd \
			nodejs npm python python-pip imagemagick xclip wl-clipboard
	elif have zypper; then
		sudo_ zypper install -y git curl unzip tar gzip gcc gcc-c++ make ripgrep fd \
			nodejs npm python3 python3-pip ImageMagick xclip wl-clipboard
	elif have apk; then
		sudo_ apk add git curl unzip tar gzip build-base ripgrep fd nodejs npm python3 py3-pip \
			imagemagick xclip wl-clipboard
	else
		warn "unknown package manager; install git, curl, unzip, gcc, make, ripgrep, fd, node, python3 yourself"
		return 0
	fi
}

install_neovim() {
	if have nvim; then
		local cur
		cur="$(nvim --version | head -n1 | sed 's/^NVIM v//; s/-.*//')"
		if version_ge "$cur" "$NVIM_MIN"; then
			log "neovim $cur is new enough"
			return 0
		fi
		warn "neovim $cur is older than $NVIM_MIN; installing the latest release to ~/.local"
	fi
	[ -n "$NVIM_ARCH" ] || { warn "no prebuilt neovim for $(uname -m); install >= $NVIM_MIN manually"; return 1; }

	local tarball="nvim-linux-${NVIM_ARCH}.tar.gz"
	local tmp
	tmp="$(mktemp -d)"
	curl -fL "https://github.com/neovim/neovim/releases/latest/download/$tarball" -o "$tmp/$tarball"
	rm -rf "$HOME/.local/opt/nvim"
	mkdir -p "$HOME/.local/opt" "$LOCAL_BIN"
	tar -xzf "$tmp/$tarball" -C "$HOME/.local/opt"
	mv "$HOME/.local/opt/nvim-linux-${NVIM_ARCH}" "$HOME/.local/opt/nvim"
	ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$LOCAL_BIN/nvim"
	rm -rf "$tmp"
	log "installed $("$LOCAL_BIN/nvim" --version | head -n1) to $LOCAL_BIN/nvim"
}

install_tree_sitter_cli() {
	# nvim-treesitter's `main` branch needs the CLI to build parsers
	if have tree-sitter; then return 0; fi
	[ -n "$TS_ARCH" ] || { warn "no prebuilt tree-sitter CLI for $(uname -m); run: npm i -g tree-sitter-cli"; return 0; }
	mkdir -p "$LOCAL_BIN"
	curl -fL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${TS_ARCH}.gz" |
		gunzip >"$LOCAL_BIN/tree-sitter"
	chmod +x "$LOCAL_BIN/tree-sitter"
	log "installed tree-sitter CLI to $LOCAL_BIN/tree-sitter"
}

link_config() {
	if [ "$REPO_DIR" = "$CONFIG_DIR" ]; then
		return 0
	fi
	if [ -e "$CONFIG_DIR" ] || [ -L "$CONFIG_DIR" ]; then
		if [ "$(readlink -f "$CONFIG_DIR")" = "$REPO_DIR" ]; then return 0; fi
		local backup
		backup="$CONFIG_DIR.bak.$(date +%Y%m%d%H%M%S)"
		log "backing up existing $CONFIG_DIR -> $backup"
		mv "$CONFIG_DIR" "$backup"
	fi
	mkdir -p "$(dirname "$CONFIG_DIR")"
	ln -s "$REPO_DIR" "$CONFIG_DIR"
	log "linked $CONFIG_DIR -> $REPO_DIR"
}

install_plugins() {
	export PATH="$LOCAL_BIN:$PATH"
	log "installing plugins at the versions pinned in lazy-lock.json"
	nvim --headless "+Lazy! restore" +qa
	log "building treesitter parsers"
	nvim --headless -c 'lua require("nvim-treesitter").install({
		"vimdoc", "javascript", "typescript", "java", "python", "rust",
		"c", "lua", "vim", "query", "markdown", "markdown_inline",
	}):wait(600000)' +qa || warn "some parsers failed; run :TSUpdate inside nvim"
}

if [ "$WITH_DEPS" -eq 1 ]; then
	log "installing system packages"
	install_packages || warn "package install failed or sudo unavailable; continuing"
	install_neovim
	install_tree_sitter_cli
fi
link_config
install_plugins

case ":$PATH:" in
*":$LOCAL_BIN:"*) ;;
*) warn "add $LOCAL_BIN to your PATH (e.g. in ~/.zshrc: export PATH=\"\$HOME/.local/bin:\$PATH\")" ;;
esac
log "done. Language servers install via Mason on first launch (see :Mason)."
