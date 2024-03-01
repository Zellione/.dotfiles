return {
	-- "folke/tokyonight.nvim",
	-- lazy = false,
	-- priority = 1000,
	-- config = function()
	-- 	vim.cmd.colorscheme("tokyonight-night")
	--
	-- 	vim.cmd.hi("Comment gui=none")
	-- end,
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		vim.cmd.colorscheme("catppuccin-macchiato")

		vim.cmd.hi("Comment gui=none")
	end,
}
