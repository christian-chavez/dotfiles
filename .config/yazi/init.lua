require("full-border"):setup { type = ui.Border.THICK }

function Entity:icon()
	local icon = th.icon:match(self._file, { hovered = self._file.is_hovered })
	if not icon then
		return ""
	elseif self._file.is_hovered then
		return icon.text .. "  "
	else
		return ui.Line(icon.text .. "  "):style(icon.style)
	end
end
require('bookmarks'):setup({
	persist = 'all',
})

function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

-- see symlinks in status bar
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

