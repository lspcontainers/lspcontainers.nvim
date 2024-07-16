local configs = require 'lspconfig.configs'
local lspcontainers = require 'lspcontainers'

-- Inspired from https://github.com/neovim/nvim-lspconfig/blob/master/scripts/docgen.lua
local function require_supported_configs()
    -- Configs are lazy-loaded, tickle them to populate the `configs` singleton.
    for language_server, _ in pairs(lspcontainers.supported_languages) do
        configs[language_server] = require('lspconfig.server_configurations.' .. language_server)
    end
end

require_supported_configs()

describe('lspcontainers', function()
    it('should have lspconfig support for each', function()
        local emoji_bad = '❌'
        local emoji_ok = '✅'
        local not_found = 0

        for lsp_name, _ in pairs(lspcontainers.supported_languages) do
            if vim.tbl_contains(vim.tbl_keys(configs), lsp_name) then
                print(lsp_name, emoji_ok)
            else
                print(lsp_name, emoji_bad)
                not_found = not_found + 1
            end
        end

        print("\n")

        assert.are.same(0, not_found)
    end)
end)
