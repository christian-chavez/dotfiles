local M = {}

function M.tag_complete(findstart, base)
  local tagfile = vim.fn.expand('~/.cache/zettelkasten-tags.txt')

  if findstart == 1 then
    local line = vim.fn.getline('.')
    local col = vim.fn.col('.') - 1
    local start = col

    while start > 0 do
      local ch = line:sub(start, start)
      if ch:match('[%w_-]') then
        start = start - 1
      else
        break
      end
    end

    return start
  end

  local items = {}
  local f = io.open(tagfile, 'r')
  if not f then
    return items
  end

  for tag in f:lines() do
    if tag:sub(1, #base) == base then
      table.insert(items, tag)
    end
  end

  f:close()
  return items
end

function M.setup()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
      _G.zettelkasten_tag_complete = M.tag_complete
      vim.bo.completefunc = 'v:lua.zettelkasten_tag_complete'
      vim.keymap.set('i', '<C-a>', '<C-x><C-u>', { buffer = true, noremap = true })
    end,
  })
end

return M
