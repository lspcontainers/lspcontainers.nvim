-- default command to run the lsp container
local default_cmd = function (runtime, workdir, image, network)

  if vim.fn.has("win32") then
    workdir = Dos2UnixSafePath(workdir)
  end

  local volume = workdir..":"..workdir

  return {
    runtime,
    "container",
    "run",
    "--interactive",
    "--rm",
    "--network="..network,
    "--workdir="..workdir,
    "--volume="..volume,
    image
  }
end

local supported_languages = {
  bashls = { image = "lspcontainers/bash-language-server:1.17.0" },
  clangd = { image = "lspcontainers/clangd-language-server:11.1.0" },
  dockerls = { image = "lspcontainers/docker-language-server:0.4.1" },
  gopls = {
    cmd_builder = function (runtime, workdir, image, network)
      local volume = workdir..":"..workdir
      local env = vim.api.nvim_eval('environ()')
      local gopath = env.GOPATH or env.HOME.."/go"
      local gopath_volume = gopath..":"..gopath

      local group_handle = io.popen("id -g")
      local user_handle = io.popen("id -u")

      local group_id = string.gsub(group_handle:read("*a"), "%s+", "")
      local user_id = string.gsub(user_handle:read("*a"), "%s+", "")

      group_handle:close()
      user_handle:close()

      local user = user_id..":"..group_id

      -- add ':z' to podman volumes to avoid permission denied errors
      if runtime == "podman" then
        gopath_volume = gopath..":"..gopath..":z"
        volume = volume..":z"
      end

      return {
        runtime,
        "container",
        "run",
        "--env",
        "GOPATH="..gopath,
        "--interactive",
        "--network="..network,
        "--rm",
        "--workdir="..workdir,
        "--volume="..volume,
        "--volume="..gopath_volume,
        "--user="..user,
        image
      }
    end,
    image = "lspcontainers/gopls:0.7.4",
    network="bridge",
  },
  html = { image = "lspcontainers/html-language-server:1.4.0" },
  intelephense = { image = "lspcontainers/intelephense:1.7.1" },
  jsonls = { image = "lspcontainers/json-language-server:1.3.4" },
  omnisharp = { image = "lspcontainers/csharp-language-server:1.37.14" },
  powershell_es = { image = "lspcontainers/powershell-language-server:2.5.1" },
  pylsp = { image = "lspcontainers/python-lsp-server:1.1.0" },
  pyright = { image = "lspcontainers/pyright-langserver:1.1.137" },
  rust_analyzer = { image = "lspcontainers/rust-analyzer:2021-05-03" },
  solargraph = { image = "lspcontainers/solargraph:0.43.0" },
  svelte = { image = "lspcontainers/svelte-language-server:0.14.3" },
  sumneko_lua = { image = "lspcontainers/lua-language-server:2.4.2" },
  terraformls = { image = "lspcontainers/terraform-ls:0.19.1" },
  tsserver = { image = "lspcontainers/typescript-language-server:0.5.1" },
  yamlls = { image = "lspcontainers/yaml-language-server:0.18.0" },
  vuels = { image = "lspcontainers/vue-language-server:0.7.2" }
}

local function command(server, user_opts)
  -- Start out with the default values:
  local opts =  {
    container_runtime = "docker",
    root_dir = vim.fn.getcwd(),
    cmd_builder = default_cmd,
    network = "none",
  }

  -- If the LSP is known, it override the defaults:
  if supported_languages[server] ~= nil then
    opts = vim.tbl_extend("force", opts, supported_languages[server])
  end

  -- If any opts were passed, those override the defaults:
  if user_opts ~= nil then
    opts = vim.tbl_extend("force", opts, user_opts)
  end

  if not opts.image then
    error(string.format("lspcontainers: no image specified for `%s`", server))
    return 1
  end

  return opts.cmd_builder(opts.container_runtime, opts.root_dir, opts.image, opts.network)
end

Dos2UnixSafePath = function(workdir)
  workdir = string.gsub(workdir, ":", "")
  workdir = string.gsub(workdir, "\\", "/")
  workdir = "/" .. workdir
  return workdir
end

return {
  command = command,
  supported_languages = supported_languages
}
