require("myconfig")
vim.o.number = true
vim.o.relativenumber = true

-- Colorscheme
vim.o.background = "dark"
vim.cmd.colorscheme("catppuccin-macchiato")  
-- vim.cmd("colorscheme onenord")
-- vim.cmd("colorscheme nordfox")

vim.cmd('syntax enable')
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.formatoptions:remove({ 'r', 'o', 'c' })
vim.cmd(":command Q q")
vim.cmd(":command W w")
vim.cmd(":command Wq wq")
vim.cmd(":command WQ wq")

-- delete word forward
vim.keymap.set('i', '<A-d>', '<C-o>de', { noremap = true })
vim.keymap.set('i', '<C-r>', '<C-g>u<C-r>', { noremap = true })
-- turn off highlighting after some search
vim.keymap.set('n', '<F3>', ':set hlsearch!<CR>', { noremap = true, silent = true })

-- options
vim.opt.tabstop = 4
vim.opt.wrap = true
vim.opt.linebreak = true

require('lualine').setup {
		options = {
				theme = "auto"
		}
}

require'nvim-treesitter.configs'.setup {
		ensure_installed = { "latex", "lua", "vim", "bash", "python" }, -- add what you use
		highlight = { enable = true },
}


-- zettelkasten tags
require('myconfig.zettelkasten').setup()
