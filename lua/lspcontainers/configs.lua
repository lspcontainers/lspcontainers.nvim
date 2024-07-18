local function gopls_command(runtime, workdir, image, network)
    local volume = workdir .. ":" .. workdir .. ":z"
    local env = vim.api.nvim_eval('environ()')
    local gopath = env.GOPATH or env.HOME .. "/go"
    local gopath_volume = gopath .. ":" .. gopath .. ":z"

    local group_handle = io.popen("id -g")
    local user_handle = io.popen("id -u")

    local group_id = string.gsub(group_handle:read("*a"), "%s+", "")
    local user_id = string.gsub(user_handle:read("*a"), "%s+", "")

    group_handle:close()
    user_handle:close()

    local user = user_id .. ":" .. group_id

    if runtime == "docker" then
        network = "bridge"
    elseif runtime == "podman" then
        network = "slirp4netns"
    end

    return {
        runtime,
        "container",
        "run",
        "--env",
        "GOPATH=" .. gopath,
        "--interactive",
        "--network=" .. network,
        "--rm",
        "--workdir=" .. workdir,
        "--volume=" .. volume,
        "--volume=" .. gopath_volume,
        "--user=" .. user,
        image
    }
end

local server_configuration = {
    bashls = { image = "docker.io/lspcontainers/bash-language-server" },
    clangd = { image = "docker.io/lspcontainers/clangd-language-server" },
    denols = { image = "docker.io/lspcontainers/denols" },
    dockerls = { image = "docker.io/lspcontainers/docker-language-server" },
    gopls = { cmd_builder = gopls_command, image = "docker.io/lspcontainers/gopls" },
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
