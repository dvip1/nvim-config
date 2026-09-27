return {
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G" },
		keys = { { "<leader>gs", vim.cmd.Git, desc = "Git status" } },
	},

	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signs_staged = {
				add = { text = "┃" },
				change = { text = "┃" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signs_staged_enable = true,
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = true,
			watch_gitdir = { follow_files = true },
			auto_attach = true,
			attach_to_untracked = false,
			preview_config = {
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				vim.keymap.set("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end, { buffer = bufnr, desc = "Git Blame Line" })
				vim.keymap.set("n", "<leader>gd", gs.preview_hunk, { buffer = bufnr, desc = "Preview Git Hunk" })
			end,
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 100,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
		},
	},
}
