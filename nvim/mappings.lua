local M = {}

M.abc = { n = { ["<leader>fm"] = {
	function()
		vim.lsp.buf.format({ async = true })
	end,
	"LSP formatting",
} } }

return M
