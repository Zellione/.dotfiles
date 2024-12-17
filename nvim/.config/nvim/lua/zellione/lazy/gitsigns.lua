return {
    'lewis6991/gitsigns.nvim',
    opts = {
        signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '‾' },
            changedelete = { text = '~' }
        }
    },
	config = function(_, opts)
		require("gitsigns").setup(opts)

		vim.keymap.set("n", "<leader>gb", "<CMD>Gitsigns toggle_current_line_blame<cr>")
		vim.keymap.set("n", "<leader>gbf", "<CMD>Gitsigns blame<cr>")
	end,
}
