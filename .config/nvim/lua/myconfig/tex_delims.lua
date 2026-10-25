-- blink.cmp source: right after a backslash, offer \(\) the way LaTeX
-- Workshop's \ menu did. Enter leaves the cursor between the two.
local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

-- makes a typed \ open the menu; without it blink waits for a letter
function source:get_trigger_characters()
  return { '\\' }
end

function source:get_completions(ctx, callback)
  local items = {}
  local row, col = ctx.cursor[1] - 1, ctx.cursor[2]
  if ctx.line:sub(1, col):match('\\$') then
    items[1] = {
      label = '\\(\\)',
      kind = require('blink.cmp.types').CompletionItemKind.Snippet,
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
      -- replaces the \ that is already typed
      textEdit = {
        newText = '\\\\($1\\\\)$0',
        range = {
          start = { line = row, character = col - 1 },
          ['end'] = { line = row, character = col },
        },
      },
    }
  end
  callback({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
end

return source
