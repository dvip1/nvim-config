-- Leader must be set before lazy.nvim loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("dvippatel.set")
require("dvippatel.remap")
require("dvippatel.lazy")

-- Netrw file previews
vim.g.netrw_preview = 1
vim.g.netrw_winsize = 25
vim.g.netrw_preview_on_the_right = 1
