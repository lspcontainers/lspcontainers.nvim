local commands = require("lspcontainers.commands")

local server_configuration = {
    bashls = { image = "docker.io/lspcontainers/bash-language-server" },
    clangd = { image = "docker.io/lspcontainers/clangd-language-server" },
    denols = { image = "docker.io/lspcontainers/denols" },
    dockerls = { image = "docker.io/lspcontainers/docker-language-server" },
    gopls = { cmd_builder = commands.command_gopls, image = "docker.io/lspcontainers/gopls" },
    graphql = { image = "docker.io/lspcontainers/graphql-language-service-cli" },
    html = { image = "docker.io/lspcontainers/html-language-server" },
    intelephense = { image = "docker.io/lspcontainers/intelephense" },
    jsonls = { image = "docker.io/lspcontainers/json-language-server" },
    omnisharp = { image = "docker.io/lspcontainers/omnisharp" },
    powershell_es = { image = "docker.io/lspcontainers/powershell-language-server" },
    prismals = { image = "docker.io/lspcontainers/prisma-language-server" },
    pylsp = { image = "docker.io/lspcontainers/python-lsp-server" },
    pyright = { image = "docker.io/lspcontainers/pyright-langserver" },
    rust_analyzer = { image = "docker.io/lspcontainers/rust-analyzer" },
    solargraph = { image = "docker.io/lspcontainers/solargraph" },
    lemminx = { image = "docker.io/lspcontainers/lemminx" },
    lua_ls = { image = "docker.io/lspcontainers/lua-language-server" },
    svelte = { image = "docker.io/lspcontainers/svelte-language-server" },
    tailwindcss = { image = "docker.io/lspcontainers/tailwindcss-language-server" },
    terraformls = { image = "docker.io/lspcontainers/terraform-ls" },
    tsserver = { image = "docker.io/lspcontainers/typescript-language-server" },
    vuels = { image = "docker.io/lspcontainers/vue-language-server" },
    yamlls = { image = "docker.io/lspcontainers/yaml-language-server" },
}

return {
    server_configuration = server_configuration
}
