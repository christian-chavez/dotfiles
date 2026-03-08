
-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use 'EdenEast/nightfox.nvim'
  use 'rmehri01/onenord.nvim'

  -- VimTeX plugin setup
  -- use { 'lervag/vimtex',
  --   ft = 'tex',  -- Only load for tex files
  --   config = function()
  --     -- VimTeX configuration
  --     -- vim.g.vimtex_latexmk_progname= '/usr/bin/nvr'
  --     vim.g.tex_flavor = 'latex'
  --     vim.g.vimtex_view_method = 'zathura'
  --     vim.g.vimtex_view_automatic = 1  -- Automatically open the PDF after compilation
  --     vim.g.vimtex_compiler_latexmk = {
  --       out_dir = '_temp',  -- Set the output directory
  --       options = {
  --         '-verbose',
  --         '-shell-escape',
  --         '-file-line-error',
  --         '-synctex=1',
  --         '-interaction=nonstopmode',
  --       }
  --     }
  --  -- 2025-09-15 next 3 taken from Gilles
  --  -- vim.g.vimtex_quickfix_mode=0
  --  -- vim.o.conceallevel=1
  --  -- vim.g.tex_conceal='abdmg'
  --  --
  --     -- vim.g.vimtex_quickfix_open_on_warning = 0
  --     --
  --     -- Configure inverse search
  --     -- vim.g.vimtex_view_general_viewer = 'zathura'
  --     -- vim.g.vimtex_view_general_options = '--synctex-forward %l:1:%f %p'
  --   end
  -- }
  -- UltiSnips plugin
  -- use {
  --   'SirVer/ultisnips',
  --   config = function()
  --     vim.g.UltiSnipsExpandTrigger = "<tab>"
  --     vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
  --     vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
  --     vim.g.UltiSnipsEditSplit = "vertical"
  --   end
  -- }
  -- -- Snippet collections
  -- use 'honza/vim-snippets'
  -- 2025-09-12 colorscheme
  use { "catppuccin/nvim", as = "catppuccin" }
  use {
		  'nvim-lualine/lualine.nvim',
		  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'ThePrimeagen/vim-be-good'

-- Autolist plugin for automatic list numbering
  use {
    "gaoDean/autolist.nvim",
    ft = { "markdown", "text", "tex", "plaintex" },
    setup = function()
      -- 'setup' runs on startup, preparing the keymaps safely
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "tex", "plaintex" },
        callback = function(args)
          local opts = { buffer = args.buf } -- Locks the keymap to this specific buffer

          vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", opts)
          vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", opts)
          vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", opts)
          vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>", opts)
        end,
      })
    end,
    config = function()
      -- 'config' only runs when a markdown/tex file is actually opened
      require("autolist").setup()
    end
  }
end)

