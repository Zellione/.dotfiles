return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup {
            ensure_installed = {'bash', 'c', 'cpp', 'html', 'lua', 'markdown', 'vim', 'vimdoc', 'rust', 'javascript', 'typescript', 'jsdoc' },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true }
        }
    end
}
