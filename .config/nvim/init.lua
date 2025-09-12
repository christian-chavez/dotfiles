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
vim.cmd(":command Q q")
vim.cmd(":command W w")
vim.cmd(":command Wq wq")
vim.cmd(":command WQ wq")

vim.opt.tabstop = 4
