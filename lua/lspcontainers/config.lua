local defaults = {
    backend = "docker",
    ensure_installed = {},
    nix = {
        runtime = "nix",
        channel = "github:nixos/nixpkgs/nixpkgs-unstable",
        extraOptions = {},
    },
    docker = {},
}

local M = vim.deepcopy(defaults)

M.setup = function(config)
    -- reset M to default when calling setup
    if not vim.deep_equal(M, defaults) then
        for k, v in pairs(defaults) do M[k] = v   end
    end

    -- apply user supplied config to M
    for k, v in pairs(vim.tbl_deep_extend("force", M, config)) do M[k] = v end

    return M
end

return M
