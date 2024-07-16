local function get_runtime()
    if Config.runtime ~= "docker" and Config.runtime ~= "podman" then
        error("lspcontainers: invalid runtime specified, defaulting to docker")
    end

    return Config.runtime
end

return {
    get_runtime = get_runtime,
}
