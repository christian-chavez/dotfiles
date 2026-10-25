-- Plugins, managed by nvim's built-in vim.pack (replaced packer.nvim on 2026-10-24).
--   Add:     a line below, then restart nvim: it installs on start
--   Update:  :lua vim.pack.update()   then :w to apply, :q to cancel
--   Remove:  delete the line, restart, then :lua vim.pack.del({ 'name' })
-- Installed versions are recorded in ~/.config/nvim/nvim-pack-lock.json.

local gh = function(repo) return 'https://github.com/' .. repo end

-- after nvim-treesitter changes, rebuild its parsers to match
-- (a fresh install gets them from ensure_installed in init.lua)
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pack-hooks', {}),
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  -- colorschemes (tokyonight is the one in use, see init.lua)
  gh('folke/tokyonight.nvim'),
  gh('EdenEast/nightfox.nvim'),
  gh('rmehri01/onenord.nvim'),
  { src = gh('catppuccin/nvim'), name = 'catppuccin' },

  gh('nvim-lualine/lualine.nvim'),
  -- master is frozen but keeps nvim-treesitter.configs, which init.lua uses; main dropped it
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'master' },
  gh('ThePrimeagen/vim-be-good'),

  -- LaTeX (settings in lua/myconfig/latex.lua)
  -- VimTeX must load at startup, not lazily: inverse search from zathura needs it
  gh('lervag/vimtex'),
  gh('L3MON4D3/LuaSnip'),
  -- v1 releases only: main is the unreleased v2
  { src = gh('saghen/blink.cmp'), version = vim.version.range('1') },
  gh('gaoDean/autolist.nvim'),
}, { confirm = false })

-- autolist: continue numbered and bulleted lists
require('autolist').setup()
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('autolist-keys', {}),
  pattern = { 'markdown', 'text', 'tex', 'plaintex' },
  callback = function(args)
    local opts = { buffer = args.buf }

    -- in tex, blink.cmp takes over <CR> and keeps this one as its fallback;
    -- mapping it again when the buffer reloads (:e!) would take Enter
    -- away from the completion menu
    local cr = vim.fn.maparg('<CR>', 'i', false, true)
    if not (cr.desc and vim.startswith(cr.desc, 'blink.cmp: ')) then
      vim.keymap.set('i', '<CR>', '<CR><cmd>AutolistNewBullet<cr>', opts)
    end
    vim.keymap.set('n', 'o', 'o<cmd>AutolistNewBullet<cr>', opts)
    vim.keymap.set('n', 'O', 'O<cmd>AutolistNewBulletBefore<cr>', opts)
    vim.keymap.set('n', 'dd', 'dd<cmd>AutolistRecalculate<cr>', opts)
  end,
})
