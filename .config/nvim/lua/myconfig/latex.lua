-- LaTeX, ported from the VSCode + LaTeX Workshop setup:
-- VimTeX builds and talks to zathura, LuaSnip runs the snippets that came over
-- from VSCode (snippets/latex.json), blink.cmp shows the completion menu
local M = {}

-- start latexmk -pvc if it isn't running yet; from then on it rebuilds by
-- itself on every save (LaTeX Workshop's autoBuild onSave)
local function ensure_compiling()
  -- on separate lines: VimtexCompile would take `| endif` as its argument
  vim.cmd([[
    if exists('b:vimtex') && !b:vimtex.compiler.is_running()
      VimtexCompile
    endif
  ]])
end

-- ctrl+click in zathura moves nvim's cursor, but VimTeX only raises the
-- terminal for viewers it launches itself, not our wrapper. alacritty puts its
-- window in $WINDOWID; VimTeX's own lookup (it also moves the mouse) is the
-- fallback when that isn't set
local function focus_terminal()
  local win = vim.env.WINDOWID
  if win and win ~= '' and vim.fn.executable('xdotool') == 1 then
    vim.system({ 'xdotool', 'windowactivate', win })
  else
    vim.cmd('call b:vimtex.viewer.xdo_focus_vim()')
  end
end

-- VimTeX only takes a file with \documentclass as a main file, but the CV
-- stubs get theirs from preamble.tex. LaTeX Workshop went by \begin{document},
-- so do the same for files that have that and no \documentclass
-- (runs on BufReadPre, before VimTeX looks, so the lines come from disk)
local function main_by_begin_document(args)
  if vim.fn.filereadable(args.match) == 0 then return end
  local has_begin = false
  for _, line in ipairs(vim.fn.readfile(args.match)) do
    if line:match('^%s*\\documentclass') then return end
    has_begin = has_begin or line:match('^%s*\\begin{document}') ~= nil
  end
  if has_begin then
    vim.b[args.buf].vimtex_main = args.match
  end
end

-- VimTeX links nearly every command to the same group, so \begin, \item,
-- \label and math all came out one color. Give each kind of thing its own
-- role, in whatever palette the colorscheme has
local roles = {
  texCmdEnv = 'Keyword', texCmdItem = 'Keyword',   -- \begin \end \item
  texEnvArgName = 'Type',                           -- {definition}
  texCmdPart = 'Title', texPartArgTitle = 'Title',  -- \chapter{...} \section{...}
  texCmd = 'Function',                              -- \textbf \centering \red
  texRefArg = 'Constant',                           -- ref / label / cite keys
  texMathZone = 'String',                           -- the math itself
  texMathCmd = 'Special',                           -- \lambda \in
}
local function color_roles()
  for group, to in pairs(roles) do
    vim.api.nvim_set_hl(0, group, { link = to })
  end
end

function M.setup()
  -- VimTeX reads these when the first tex buffer opens, so set them up front.
  -- Engine (xelatex, lualatex) and $out_dir from a project's .latexmkrc still
  -- win over what is here, same as before.
  vim.g.vimtex_compiler_latexmk = {
    out_dir = '_temp',
    options = {
      '-shell-escape',
      '-verbose',
      '-file-line-error',
      '-synctex=1',
      '-interaction=nonstopmode',
    },
  }
  -- open PDFs through the wrapper so they show up in the rofi recent list;
  -- a second call on an already open PDF just does the forward search in it.
  -- Inverse search (ctrl+click in zathura) is synctex-editor-command in zathurarc
  vim.g.vimtex_view_method = 'general'
  vim.g.vimtex_view_general_viewer = 'zathura-recent-files-rofi'
  vim.g.vimtex_view_general_options = '--synctex-forward @line:@col:@tex @pdf'
  -- errors were hidden in VSCode too; :VimtexErrors (\le) shows them
  vim.g.vimtex_quickfix_mode = 0
  -- ts$ swaps \[ \] and \( \) (the old ctrl+alt+d)
  vim.g.vimtex_env_toggle_math_map = {
    ['$'] = '\\[',
    ['$$'] = '\\[',
    ['\\['] = '\\(',
    ['\\('] = '\\[',
  }

  require('luasnip.loaders.from_vscode').lazy_load({
    paths = { vim.fn.stdpath('config') .. '/snippets' },
  })

  require('blink.cmp').setup({
    -- only in tex for now, markdown keeps its own <C-a> tag completion
    enabled = function() return vim.bo.filetype == 'tex' end,
    -- Enter accepts, Tab/S-Tab jump between snippet fields, like VSCode
    keymap = { preset = 'enter' },
    snippets = { preset = 'luasnip' },
    -- omni is VimTeX: \ref{, \cite{, \begin{, commands from loaded packages
    sources = {
      default = { 'snippets', 'omni', 'path', 'buffer' },
      providers = {
        -- inside \ref{ or \cite{ only VimTeX's labels/keys show; snippets and
        -- words from the file (which repeat the keys) come back when it has none
        omni = { score_offset = 5, fallbacks = { 'snippets', 'buffer' } },
        -- blink ranks snippets below plain words by default, so `thm` + Enter
        -- would pick the word thm (from \label{thm:...}) instead of expanding
        snippets = { score_offset = 4 },
      },
    },
  })

  local group = vim.api.nvim_create_augroup('myconfig-latex', {})
  -- a colorscheme clears all highlights, so set the roles again after one
  color_roles()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = color_roles,
  })
  vim.api.nvim_create_autocmd('BufReadPre', {
    group = group,
    pattern = '*.tex',
    callback = main_by_begin_document,
  })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'VimtexEventViewReverse',
    callback = focus_terminal,
  })
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    pattern = '*.tex',
    callback = ensure_compiling,
  })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'tex',
    callback = function(args)
      local opts = { buffer = args.buf }
      -- F2 was "build" in VSCode
      vim.keymap.set('n', '<F2>', function()
        vim.cmd('silent update')
        ensure_compiling()
      end, opts)
      vim.keymap.set('n', '<C-A-d>', '<Plug>(vimtex-env-toggle-math)', opts)
      -- paragraphs are one long wrapped line: move by screen line unless a
      -- count is given, so relative-number jumps like 5j still work
      vim.keymap.set({ 'n', 'x' }, 'j', "v:count ? 'j' : 'gj'", { buffer = args.buf, expr = true })
      vim.keymap.set({ 'n', 'x' }, 'k', "v:count ? 'k' : 'gk'", { buffer = args.buf, expr = true })
    end,
  })
end

return M
