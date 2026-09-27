return {
	-- Harpoon 2 (same keys as before)
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("harpoon"):setup()
		end,
		keys = {
			{ "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
			{
				"<C-e>",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon menu",
			},
			{ "<C-h>", function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
			{ "<C-t>", function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
			{ "<C-n>", function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
			{ "<C-s>", function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
		},
	},

	{
		"mbbill/undotree",
		keys = { { "<leader>u", vim.cmd.UndotreeToggle, desc = "Undotree" } },
	},

	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		opts = {
			mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>" },
			hide_cursor = true,
			stop_eof = true,
			respect_scrolloff = false,
			cursor_scrolls_alone = true,
			duration_multiplier = 1.0,
			easing = "linear",
			performance_mode = false,
			ignored_events = { "WinScrolled", "CursorMoved" },
		},
	},

	{ "chentoast/marks.nvim", event = "VeryLazy", opts = {} },

	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons", "datsfilipe/vesper.nvim" },
		config = function()
			local ok, vesper = pcall(require, "vesper")
			require("bufferline").setup({
				highlights = ok and vesper.bufferline and vesper.bufferline.highlights or nil,
			})
		end,
	},

	-- Image preview (kitty graphics protocol; in tmux needs `set -g allow-passthrough on`)
	{
		"3rd/image.nvim",
		ft = { "markdown", "vimwiki", "norg", "typst" },
		event = { "BufReadPre *.png,*.jpg,*.jpeg,*.gif,*.webp,*.avif" },
		cond = function()
			return vim.fn.executable("magick") == 1
		end,
		opts = {
			backend = "kitty",
			processor = "magick_cli", -- no luarock needed
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki" },
				},
				neorg = { enabled = true, filetypes = { "norg" } },
				typst = { enabled = true, filetypes = { "typst" } },
				html = { enabled = false },
				css = { enabled = false },
			},
			max_height_window_percentage = 100,
			window_overlap_clear_enabled = false,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			editor_only_render_when_focused = false,
			tmux_show_only_in_active_window = false,
			hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
		},
	},

	{
		"nomnivore/ollama.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = { "Ollama", "OllamaModel", "OllamaServe", "OllamaServeStop" },
		opts = {},
	},
}
