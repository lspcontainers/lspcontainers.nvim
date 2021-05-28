local configs = require 'lspconfig/configs'
local lspcontainers = require 'lspcontainers'

-- Copied from https://github.com/neovim/nvim-lspconfig/blob/master/scripts/docgen.lua
local function require_all_configs()
  -- Configs are lazy-loaded, tickle them to populate the `configs` singleton.
  for _,v in ipairs(vim.fn.glob('nvim-lspconfig/lua/lspconfig/*.lua', 1, 1)) do
    local module_name = v:gsub('.*/', ''):gsub('%.lua$', '')
    require('lspconfig/'..module_name)
  end
end

require_all_configs()
local known_lsp_configs = vim.tbl_keys(configs)

local test_succeed = true
local emoji_ok = '✅'
local emoji_bad = '❌'

for language_server, _ in pairs(lspcontainers.supported_languages) do
  if vim.tbl_contains(known_lsp_configs, language_server) then
    print(language_server, emoji_ok)
  else
    print(language_server, emoji_bad)
    test_succeed = false
  end
end

print("\n")
os.exit(test_succeed)
