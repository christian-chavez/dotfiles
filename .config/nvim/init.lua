require("myconfig")
vim.o.number = true
vim.o.relativenumber = true

-- Colorscheme
vim.o.background = "dark"
require('tokyonight').setup({ style = 'night' })
vim.cmd.colorscheme("tokyonight-night")
-- vim.cmd.colorscheme("catppuccin-macchiato")
-- vim.cmd("colorscheme onenord")
-- vim.cmd("colorscheme nordfox")

vim.opt.clipboard = "unnamedplus"
-- Same as the builtin xclip provider, but with xclip's output discarded. The
-- builtin one pipes xclip's stderr back to nvim, so once nvim exits (e.g. its
-- window is closed) xclip dies of SIGPIPE on greenclip's next poll and the
-- clipboard ends up empty. Detached this way, the yank outlives nvim.
vim.g.clipboard = {
		name = "xclip-persistent",
		copy = {
				["+"] = { "sh", "-c", "exec xclip -quiet -i -selection clipboard >/dev/null 2>&1" },
				["*"] = { "sh", "-c", "exec xclip -quiet -i -selection primary >/dev/null 2>&1" },
		},
		paste = {
				["+"] = { "xclip", "-o", "-selection", "clipboard" },
				["*"] = { "xclip", "-o", "-selection", "primary" },
		},
		cache_enabled = 1,
}
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.formatoptions:remove({ 'r', 'o', 'c' })
-- formatoptions is per-buffer and filetype plugins add 'cro' back (packer even
-- re-runs them when it lazy-loads autolist), so strip them again once the
-- FileType handling is done
vim.api.nvim_create_autocmd('FileType', {
		group = vim.api.nvim_create_augroup('no-auto-comment', {}),
		callback = function(args)
				vim.schedule(function()
						if vim.api.nvim_buf_is_valid(args.buf) then
								vim.bo[args.buf].formatoptions = vim.bo[args.buf].formatoptions:gsub('[cro]', '')
						end
				end)
		end,
})
-- shift typos, also as :Q!, :W!, :W file
vim.api.nvim_create_user_command('Q', 'q<bang>', { bang = true })
vim.api.nvim_create_user_command('W', 'w<bang> <args>', { bang = true, nargs = '?', complete = 'file' })
vim.api.nvim_create_user_command('Wq', 'wq<bang> <args>', { bang = true, nargs = '?', complete = 'file' })
vim.api.nvim_create_user_command('WQ', 'wq<bang> <args>', { bang = true, nargs = '?', complete = 'file' })

-- delete word forward (like emacs M-d): any non-word chars, then the word
vim.keymap.set('i', '<A-d>', function()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local stop = vim.fn.matchend(vim.api.nvim_get_current_line(), [[\v^%(\k@!.)*\k*]], col)
		vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, stop, {})
end)
vim.keymap.set('i', '<C-r>', '<C-g>u<C-r>', { noremap = true })
-- turn off highlighting after some search
vim.keymap.set('n', '<F3>', ':set hlsearch!<CR>', { noremap = true, silent = true })

-- options
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0 -- indent by one tabstop, not the default 8
vim.opt.wrap = true
vim.opt.linebreak = true

require('lualine').setup {
		options = {
				theme = "auto"
		}
}

require'nvim-treesitter.configs'.setup {
		ensure_installed = { "latex", "lua", "vim", "bash", "python" }, -- add what you use
		highlight = {
				enable = true,
				-- VimTeX's own syntax has to stay on for tex: it knows where math starts
				disable = { "latex" },
		},
}


-- zettelkasten tags
require('myconfig.zettelkasten').setup()

-- LaTeX: VimTeX + zathura, snippets, completion
require('myconfig.latex').setup()
