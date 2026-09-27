# nvim config

Neovim (>= 0.11) config using lazy.nvim, native LSP (`vim.lsp.config`) with Mason,
nvim-treesitter (`main` branch), telescope, harpoon, and the vesper colorscheme.

## Install on a new machine

```sh
git clone <repo-url> ~/.config/nvim
~/.config/nvim/install.sh
```

`install.sh` will:

1. Install system packages with dnf / apt / pacman / zypper / apk
   (git, curl, unzip, gcc, make, ripgrep, fd, node/npm, python3, ImageMagick, clipboard tools).
2. Install the latest Neovim release to `~/.local` if the system one is older than 0.11.
3. Install the `tree-sitter` CLI to `~/.local/bin` if missing (needed to build parsers).
4. Symlink the repo to `~/.config/nvim` if you cloned it somewhere else
   (an existing config is moved to `~/.config/nvim.bak.<timestamp>`).
5. Install plugins at the exact commits in `lazy-lock.json` and build treesitter parsers.

Language servers and formatters (clangd, lua_ls, pylsp, ts_ls, gopls, prettier, stylua, ...)
are installed by Mason the first time you open Neovim. Check progress with `:Mason`.

Options: `--no-deps` skips system packages; `--no-sudo` never calls sudo.

### Optional extras

- **Go** for `gopls`/`gofumpt`, **Java 21+** for `jdtls`/Kotlin: install from your distro.
- **Image previews** need a kitty-graphics terminal (kitty, ghostty, wezterm). In tmux add
  `set -g allow-passthrough on`.
- **Ollama** for `ollama.nvim`.

## Updating

- On this machine: `:Lazy update`, then commit the changed `lazy-lock.json`.
- On other machines: `git pull`, then `:Lazy restore` to match the lock file.
