return {
    'nvim-telescope/telescope-dap.nvim',
    dependencies = {
        { 'nvim-telescope/telescope.nvim' },
        { 'mfussenegger/nvim-dap' }
    },
    config = function()
        local telescope = require('telescope')
        telescope.load_extension('dap')
        vim.keymap.set('n', '<F6>', telescope.extensions.dap.list_breakpoints, {})
        vim.keymap.set('n', '<F7>', telescope.extensions.dap.variables, {})
        vim.keymap.set('n', '<F8>', telescope.extensions.dap.commands, {})
    end
}
