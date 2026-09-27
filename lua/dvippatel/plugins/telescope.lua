return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
	cmd = "Telescope",
	keys = {
		{ "<leader>pf", function() require("telescope.builtin").find_files() end, desc = "Telescope find files" },
		{ "<C-p>", function() require("telescope.builtin").git_files() end, desc = "Telescope git files" },
		{
			"<leader>ps",
			function() require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") }) end,
			desc = "Telescope grep string",
		},
	},
	opts = {
		pickers = {
			find_files = { follow = true, hidden = true },
		},
	},
}
