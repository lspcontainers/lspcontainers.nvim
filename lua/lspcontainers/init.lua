local backends = {}
backends["docker"] = require('lspcontainers.backends.docker')
backends["nix"] = require("lspcontainers.backends.nix")

local defaultbackend = backends["docker"]

local M = {
    command = defaultbackend.command,
    images_pull = defaultbackend.images_pull,
    images_remove = defaultbackend.images_remove,
    supported_languages = defaultbackend.supported_languages,
}

local function setup(options)
    options = options or {}
    local config = require('lspcontainers.config').setup(options)

    local backend = backends[config.backend]
    assert(backend ~= nil, "configuration value backend has invalid value: \""..config.backend.."\"")

    M.command = backend.command
    M.images_pull = backend.images_pull
    M.images_remove = backend.images_remove
    M.supported_languages = backend.supported_languages

    vim.api.nvim_create_user_command("LspImagesPull", function() backend.images_pull(config) end, {})
    vim.api.nvim_create_user_command("LspImagesRemove", backend.images_remove, {})
end

M.setup = setup

return M
