require("myconfig")
vim.o.number = true
vim.o.relativenumber = true
-- vim.cmd("colorscheme nordfox")
vim.cmd("colorscheme onenord")
vim.cmd('syntax enable')
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.cmd(":command Q q")
vim.cmd(":command W w")
vim.cmd(":command Wq wq")
vim.cmd(":command WQ wq")
