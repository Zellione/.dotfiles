return {
	"ThePrimeagen/git-worktree.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("git-worktree").setup()
		require("telescope").load_extension("git_worktree")

		vim.keymap.set(
			"n",
			"<leader>st",
			"<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>",
			{ desc = "Search Worktrees", silent = true }
		)

		vim.keymap.set(
			"n",
			"<leader>sT",
			"<CMD>lua require('telescope').extensions.git_worktree.create_git_worktreet)<CR>",
			{ desc = "Create Worktree", silent = true }
		)
	end,
}
