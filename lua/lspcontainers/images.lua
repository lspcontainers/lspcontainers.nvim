local languages = require("lspcontainers.languages")
local runtimes = require("lspcontainers.runtimes")

local function on_event(_, data, event)
    --if event == "stdout" or event == "stderr" then
    if event == "stdout" then
        if data then
            for _, v in pairs(data) do
                print(v)
            end
        end
    end
end

local function pull()
    local runtime = runtimes.get_runtime()

    local jobs = {}

    for idx, server_name in ipairs(Config.ensure_installed) do
        local server = languages.server_configuration[server_name]

        local job_id =
            vim.fn.jobstart(
                runtime .. " image pull " .. server['image'],
                {
                    on_stderr = on_event,
                    on_stdout = on_event,
                    on_exit = on_event,
                }
            )

        table.insert(jobs, idx, job_id)
    end

    local _ = vim.fn.jobwait(jobs)

    print("lspcontainers: Configured language servers pulled")
end

local function remove()
    local runtime = runtimes.get_runtime()

    local jobs = {}

    for idx, server_name in ipairs(Config.ensure_installed) do
        local server = languages.server_configuration[server_name]

        local job =
            vim.fn.jobstart(
                runtime .. " image rm --force " .. server['image'] .. ":latest",
                {
                    on_stderr = on_event,
                    on_stdout = on_event,
                    on_exit = on_event,
                }
            )

        table.insert(jobs, idx, job)
    end

    local _ = vim.fn.jobwait(jobs)

    print("lspcontainers: Configured language servers removed")
end

return {
    pull = pull,
    remove = remove,
}
