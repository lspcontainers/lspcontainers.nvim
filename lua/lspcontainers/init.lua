local commands = require("lspcontainers.commands")
local configs = require("lspcontainers.configs")
local images = require("lspcontainers.images")

Config = {
    ensure_installed = {},
    runtime = "docker"
}

vim.api.nvim_create_user_command("LspImagesPull", images.pull, {})
vim.api.nvim_create_user_command("LspImagesRemove", images.remove, {})

local function setup(options)
    if options['ensure_installed'] then
        Config.ensure_installed = options['ensure_installed']
    end
end

return {
    command = commands.command,
    images_pull = images.pull,
    images_remove = images.remove,
    server_configuration = configs.server_configuration,
    setup = setup,
}
