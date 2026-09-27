return {
	{
		"datsfilipe/vesper.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("vesper").setup({
				transparent = false,
				italics = {
					comments = true,
					keywords = true,
					functions = true,
					strings = true,
					variables = true,
				},
				overrides = {},
				palette_overrides = {},
			})

			vim.cmd.colorscheme("vesper")
			-- Transparent background (ColorMyPencil)
			for _, group in ipairs({ "Normal", "NormalNC", "NormalFloat", "FloatBorder", "Pmenu" }) do
				vim.api.nvim_set_hl(0, group, { bg = "none" })
			end
			-- vesper links DiagnosticUnderline* to the fg groups, which drops the
			-- undercurl and repaints the text grey (killing syntax highlighting on
			-- whole-line diagnostics like cpplint's). Use a colored undercurl only.
			for _, sev in ipairs({ "Error", "Warn", "Info", "Hint" }) do
				local fg = vim.api.nvim_get_hl(0, { name = "Diagnostic" .. sev, link = false }).fg
				vim.api.nvim_set_hl(0, "DiagnosticUnderline" .. sev, { undercurl = true, sp = fg })
			end
		end,
	},
	-- Alternates, loaded on demand via :colorscheme
	{ "rose-pine/neovim", name = "rose-pine", lazy = true },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
}
