
-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use 'EdenEast/nightfox.nvim'
  use 'rmehri01/onenord.nvim'

  -- VimTeX plugin setup
  use { 'lervag/vimtex',
    ft = 'tex',  -- Only load for tex files
    config = function()
      -- VimTeX configuration
      -- vim.g.vimtex_latexmk_progname= '/usr/bin/nvr'
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_view_automatic = 1  -- Automatically open the PDF after compilation
      vim.g.vimtex_compiler_latexmk = {
        out_dir = '_temp',  -- Set the output directory
        options = {
          '-verbose',
          '-shell-escape',
          '-file-line-error',
          '-synctex=1',
          '-interaction=nonstopmode',
        }
      }
      -- vim.g.vimtex_quickfix_open_on_warning = 0
      --
      -- Configure inverse search
      -- vim.g.vimtex_view_general_viewer = 'zathura'
      -- vim.g.vimtex_view_general_options = '--synctex-forward %l:1:%f %p'
    end
  }
  -- UltiSnips plugin
  use {
    'SirVer/ultisnips',
    config = function()
      vim.g.UltiSnipsExpandTrigger = "<tab>"
      vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
      vim.g.UltiSnipsEditSplit = "vertical"
    end
  }
  -- Snippet collections
  use 'honza/vim-snippets'
end)

