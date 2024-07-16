local configs = require("lspcontainers.configs")
local paths = require("lspcontainers.paths")

local command_builder = function(runtime, workdir, image, network, docker_volume)
    if vim.loop.os_uname().sysname == "Windows_NT" then
        workdir = paths.dos2UnixSafePath(workdir)
    end

    local mnt_volume

    if docker_volume ~= nil then
        mnt_volume = "--volume=" .. docker_volume .. ":" .. workdir .. ":z"
    else
        mnt_volume = "--volume=" .. workdir .. ":" .. workdir .. ":z"
    end

    return {
        runtime,
        "container",
        "run",
        "--interactive",
        "--rm",
        "--network=" .. network,
        "--workdir=" .. workdir,
        mnt_volume,
        image
    }
end

local function command(server, user_opts)
    -- Start out with the default values:
    local opts = {
        cmd_builder = command_builder,
        container_runtime = "docker",
        docker_volume = nil,
        network = "none",
        root_dir = vim.fn.getcwd(),
    }

    -- If the LSP is known, it override the defaults:
    if configs.server_configuration[server] ~= nil then
        opts = vim.tbl_extend("force", opts, configs.server_configuration[server])
    end

    -- If any opts were passed, those override the defaults:
    if user_opts ~= nil then
        opts = vim.tbl_extend("force", opts, user_opts)
    end

    if not opts.image then
        error(string.format("lspcontainers: no image specified for `%s`", server))
        return 1
    end

    return opts.cmd_builder(opts.container_runtime, opts.root_dir, opts.image, opts.network, opts.docker_volume)
end

local function command_gopls(runtime, workdir, image, network)
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

return {
    command = command,
    command_gopls = command_gopls
}
