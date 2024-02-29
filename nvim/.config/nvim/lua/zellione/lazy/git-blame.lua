return {
	"f-person/git-blame.nvim",
	opts = {
		enabled = false,
		date_format = "%r",
	},
	config = function(_, opts)
		require("gitblame").setup(opts)

		vim.keymap.set("n", "<leader>gb", ":GitBlameToggle<cr>")
	end,
}
