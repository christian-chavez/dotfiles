-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/christian/.cache/nvim/packer_hererocks/2.1.1772619647/share/lua/5.1/?.lua;/home/christian/.cache/nvim/packer_hererocks/2.1.1772619647/share/lua/5.1/?/init.lua;/home/christian/.cache/nvim/packer_hererocks/2.1.1772619647/lib/luarocks/rocks-5.1/?.lua;/home/christian/.cache/nvim/packer_hererocks/2.1.1772619647/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/christian/.cache/nvim/packer_hererocks/2.1.1772619647/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["autolist.nvim"] = {
    config = { "\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rautolist\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/christian/.local/share/nvim/site/pack/packer/opt/autolist.nvim",
    url = "https://github.com/gaoDean/autolist.nvim"
  },
  catppuccin = {
    loaded = true,
    path = "/home/christian/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/home/christian/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["nightfox.nvim"] = {
    loaded = true,
    path = "/home/christian/.local/share/nvim/site/pack/packer/start/nightfox.nvim",
    url = "https://github.com/EdenEast/nightfox.nvim"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/christian/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/christian/.local/share/nvim/site/pack/packer/opt/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["onenord.nvim"] = {
    loaded = true,
    path = "/home/christian/.local/share/nvim/site/pack/packer/start/onenord.nvim",
    url = "https://github.com/rmehri01/onenord.nvim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/christian/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["vim-be-good"] = {
    loaded = true,
    path = "/home/christian/.local/share/nvim/site/pack/packer/start/vim-be-good",
    url = "https://github.com/ThePrimeagen/vim-be-good"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: autolist.nvim
time([[Setup for autolist.nvim]], true)
try_loadstring("\27LJ\2\n»\2\0\1\b\0\16\0$5\1\1\0009\2\0\0=\2\2\0016\2\3\0009\2\4\0029\2\5\2'\4\6\0'\5\a\0'\6\b\0\18\a\1\0B\2\5\0016\2\3\0009\2\4\0029\2\5\2'\4\t\0'\5\n\0'\6\v\0\18\a\1\0B\2\5\0016\2\3\0009\2\4\0029\2\5\2'\4\t\0'\5\f\0'\6\r\0\18\a\1\0B\2\5\0016\2\3\0009\2\4\0029\2\5\2'\4\t\0'\5\14\0'\6\15\0\18\a\1\0B\2\5\1K\0\1\0#dd<cmd>AutolistRecalculate<cr>\add&O<cmd>AutolistNewBulletBefore<cr>\6O o<cmd>AutolistNewBullet<cr>\6o\6n#<CR><cmd>AutolistNewBullet<cr>\t<CR>\6i\bset\vkeymap\bvim\vbuffer\1\0\1\vbuffer\0\bbufü\1\1\0\5\0\t\0\v6\0\0\0009\0\1\0009\0\2\0'\2\3\0005\3\5\0005\4\4\0=\4\6\0033\4\a\0=\4\b\3B\0\3\1K\0\1\0\rcallback\0\fpattern\1\0\2\fpattern\0\rcallback\0\1\5\0\0\rmarkdown\ttext\btex\rplaintex\rFileType\24nvim_create_autocmd\bapi\bvim\0", "setup", "autolist.nvim")
time([[Setup for autolist.nvim]], false)
vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'autolist.nvim'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType plaintex ++once lua require("packer.load")({'autolist.nvim'}, { ft = "plaintex" }, _G.packer_plugins)]]
vim.cmd [[au FileType tex ++once lua require("packer.load")({'autolist.nvim'}, { ft = "tex" }, _G.packer_plugins)]]
vim.cmd [[au FileType text ++once lua require("packer.load")({'autolist.nvim'}, { ft = "text" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
