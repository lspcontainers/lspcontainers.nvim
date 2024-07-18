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

return {
    command = command,
}
