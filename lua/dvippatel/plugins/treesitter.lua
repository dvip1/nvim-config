-- nvim-treesitter `main` branch (the old `master`/configs API is archived).
-- Needs the `tree-sitter` CLI to build parsers.
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.install({
			"vimdoc", "javascript", "typescript", "java", "python", "rust",
			"c", "lua", "vim", "query", "markdown", "markdown_inline",
		})

		local available = {}
		for _, lang in ipairs(ts.get_available()) do
			available[lang] = true
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("dvip_treesitter", { clear = true }),
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(args.match)
				if not lang then
					return
				end
				-- Start highlighting if the parser exists, otherwise auto-install it
				if not pcall(vim.treesitter.start, args.buf, lang) and available[lang] then
					ts.install(lang):await(function()
						if vim.api.nvim_buf_is_valid(args.buf) then
							pcall(vim.treesitter.start, args.buf, lang)
						end
					end)
				end
			end,
		})
	end,
}
