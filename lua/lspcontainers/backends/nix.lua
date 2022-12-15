local util = require('lspcontainers.util')
local config = require('lspcontainers.config')
local M = {}


local function get_store_path(package, channel, runtime)
    runtime = runtime or config.nix.runtime
    channel = channel or config.nix.channel

    local storepath = ""
    vim.fn.jobwait{vim.fn.jobstart(
        string.format("%s eval --raw %s#%s", runtime, channel, package),
        {
            on_stdout = function(_, data, _)
                if data then
                    for _, v in pairs(data) do
                        if string.sub(v, 1, 4) == "/nix" then
                            storepath = v
                        end
                    end
                end
            end,
        }
    )}
    return storepath
end

M.supported_languages = {
    bashls = {
        package = "nodePackages.bash-language-server",
        binary = "bash-language-server",
        arguments = { "start" },
    },
    clangd = { package = "clang-tools", },
    dockerls = { package = "docker-ls", },
    -- TODO: extend this list
}

function M.command(server, user_opts)
    -- Start out with the default values:
    local opts = config.nix

    -- If the LSP is known, it override the defaults:
    if M.supported_languages[server] ~= nil then
        opts = vim.tbl_extend("force", opts, M.supported_languages[server])
    end

    -- If any opts were passed, those override the defaults:
    if user_opts ~= nil then
        opts = vim.tbl_extend("force", opts, user_opts)
    end

    if not opts.package then
        error(string.format("lspcontainers: no package specified for `%s`", server))
        return 1
    end

    if opts.binary == nil then
        opts.binary = opts.package
    end

    local ret = {
        opts.runtime,
        "shell",
        string.format("%s#%s", opts.channel, opts.package),
        "-c",
        opts.binary,
        unpack(opts.arguments)
    }

    if opts.extraOptions ~= nil then
        assert(
            type(opts.extraOptions) == "table",
            "configuration value nix.extraOptions has invalid type: \""..type(opts.extraOptions).."\", expected table of strings")

        for i, v in ipairs(opts.extraOptions) do
            assert(
                type(v) == "string",
                "invalid value for element "..i.." in nix.extraOptions: "..type(v)..", expected string")
            table.insert(ret, 3 + i, v)
        end
    end

    return ret
end


function M.images_pull(Config, channel, runtime)
    runtime = runtime or config.nix.runtime
    channel = channel or config.nix.channel

    local jobs = {}
    for idx, server_name in ipairs(Config.ensure_installed) do
        local server = M.supported_languages[server_name]
        local channel_ = server.channel or channel

        local job_id = vim.fn.jobstart(
            string.format("%s build --no-link %s#%s", runtime, channel_, server.package),
            {
                on_stderr = util.on_event,
                on_stdout = util.on_event,
                on_exit = util.on_event,
            }
        )

        table.insert(jobs, idx, job_id)
    end
    local _ = vim.fn.jobwait(jobs)

    print("lspcontainers: Language servers successfully pulled")
end


-- lazily remove paths from the nix store -> only deletes paths if not referenced by other derivations
function M.images_remove(channel, runtime)
    local jobs = {}
    channel = channel or config.nix.channel
    runtime = runtime or config.nix.runtime

    for _, v in pairs(M.supported_languages) do
        local storepath = get_store_path(v.package, channel, runtime)
        local job = vim.fn.jobstart(
            string.format("%s store delete %s", runtime, storepath),
            {
                on_stderr = util.on_event,
                on_stdout = util.on_event,
                on_exit = util.on_event,
            }
        )

        table.insert(jobs, job)
    end

    local _ = vim.fn.jobwait(jobs)

    print("lspcontainers: All language servers removed")
end

return M
