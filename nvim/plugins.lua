local plugins = {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"jose-elias-alvarez/null-ls.nvim",
				config = function()
					require("custom.configs.null-ls")
				end,
			},
			{
				"folke/neodev.nvim",
				config = function()
					require("neodev").setup()
				end,
			},
		},
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end,
	},
	{
		"RRethy/vim-illuminate",
		config = function()
			require("custom.configs.illuminate")
		end,
		lazy = false,
	},
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"pyright",
				"rust-analyzer",
				"black",
				"stylua",
				"prettier",
				"rustfmt",
			},
		},
	},
}

return plugins
