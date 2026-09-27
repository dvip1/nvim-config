-- Uses the Neovim 0.11+ native API (vim.lsp.config / vim.lsp.enable).
-- nvim-lspconfig only supplies the default server configs; mason-lspconfig
-- installs servers and enables them automatically.
return {
	{
		"mason-org/mason.nvim",
		build = ":MasonUpdate",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("dvip_lsp_attach", { clear = true }),
				callback = function(ev)
					local map = function(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
					end
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("gd", vim.lsp.buf.definition, "Go to definition")
					map("K", vim.lsp.buf.hover, "Hover")
					map("gi", vim.lsp.buf.implementation, "Go to implementation")
					map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("gr", vim.lsp.buf.references, "References")
					map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
				end,
			})

			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})

			vim.lsp.config("pylsp", {
				settings = {
					pylsp = {
						plugins = {
							pyls_mypy = { enabled = true, live_mode = true },
						},
					},
				},
			})

			vim.lsp.config("bashls", {
				filetypes = { "sh", "bash" },
				settings = {
					bashIde = {
						globPattern = true,
						shellcheckPath = "shellcheck",
						formatter = { enableDefaultFormatter = true },
					},
				},
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
						completion = { callSnippet = "Replace" },
					},
				},
			})

			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
					"clangd",
					"kotlin_language_server",
					"gradle_ls",
					"ts_ls",
					"pylsp",
					"eslint",
					"bashls",
					"lua_ls",
					"gopls",
					"intelephense",
				},
				-- jdtls is handled by nvim-java
				automatic_enable = { exclude = { "jdtls" } },
			})
		end,
	},

	-- Formatters / linters
	{
		"nvimtools/none-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvimtools/none-ls-extras.nvim",
			"nvim-lua/plenary.nvim",
			"mason-org/mason.nvim",
			"jay-babu/mason-null-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"ast-grep",
					"gofumpt",
					"golangci-lint",
					"clang-format",
					"prettier",
					"stylua",
					"jq",
					"cpplint",
				},
				automatic_installation = true,
			})

			local null_ls = require("null-ls")
			-- Only register a source once its binary exists (mason installs them)
			local function when(bin, source)
				return source.with({
					condition = function()
						return vim.fn.executable(bin) == 1
					end,
				})
			end

			null_ls.setup({
				sources = {
					when("prettier", null_ls.builtins.formatting.prettier.with({
						extra_args = function(params)
							local args = { "--config-precedence", "prefer-file" }
							if params.options and params.options.tabSize then
								vim.list_extend(args, { "--tab-width", tostring(params.options.tabSize) })
							end
							return args
						end,
					})),
					when("stylua", null_ls.builtins.formatting.stylua),
					null_ls.builtins.completion.spell,
					when("cpplint", require("none-ls.diagnostics.cpplint")),
					when("jq", require("none-ls.formatting.jq")),
					-- eslint diagnostics/code actions come from the eslint LSP
				},
			})

			vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format, { desc = "Format buffer" })
		end,
	},

	-- Java
	{
		"nvim-java/nvim-java",
		ft = "java",
		config = function()
			require("java").setup()
			vim.lsp.enable("jdtls")
		end,
	},
}
