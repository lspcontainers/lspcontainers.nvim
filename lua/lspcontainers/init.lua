Config = {
  ensure_installed = {}
}

local supported_languages = {
  bashls = { image = "lspcontainers/bash-language-server" },
  clangd = { image = "lspcontainers/clangd-language-server" },
  dockerls = { image = "lspcontainers/docker-language-server" },
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
    image = "lspcontainers/gopls",
    network="bridge",
  },
  html = { image = "lspcontainers/html-language-server" },
  intelephense = { image = "lspcontainers/intelephense" },
  jsonls = { image = "lspcontainers/json-language-server" },
  omnisharp = { image = "lspcontainers/omnisharp" },
  powershell_es = { image = "lspcontainers/powershell-language-server" },
  pylsp = { image = "lspcontainers/python-lsp-server" },
  pyright = { image = "lspcontainers/pyright-langserver" },
  rust_analyzer = { image = "lspcontainers/rust-analyzer" },
  solargraph = { image = "lspcontainers/solargraph" },
  svelte = { image = "lspcontainers/svelte-language-server" },
  sumneko_lua = { image = "lspcontainers/lua-language-server" },
  terraformls = { image = "lspcontainers/terraform-ls" },
  tsserver = { image = "lspcontainers/typescript-language-server" },
  yamlls = { image = "lspcontainers/yaml-language-server" },
  vuels = { image = "lspcontainers/vue-language-server" }
}

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

local function images_pull()
  local jobs = {}

  for idx, server_name in ipairs(Config.ensure_installed) do
    local server = supported_languages[server_name]

    local job_id =
      vim.fn.jobstart(
      "docker image pull "..server['image'],
      {
        on_stderr = on_event,
        on_stdout = on_event,
        on_exit = on_event,
      }
    )

    table.insert(jobs, idx, job_id)
  end

  local _ = vim.fn.jobwait(jobs)

  print("lspcontainers: Language servers successfully pulled")
end

local function images_remove()
  local jobs = {}

  for _, v in pairs(supported_languages) do
    local job =
      vim.fn.jobstart(
      "docker image rm --force "..v['image']..":latest",
      {
        on_stderr = on_event,
        on_stdout = on_event,
        on_exit = on_event,
      }
    )

    table.insert(jobs, job)
  end

  local _ = vim.fn.jobwait(jobs)

  print("lspcontainers: All language servers removed")
end

vim.cmd [[
  command -nargs=0 LspImagesPull lua require'lspcontainers'.images_pull()
  command -nargs=0 LspImagesRemove lua require'lspcontainers'.images_remove()
]]

local function setup(options)
  if options['ensure_installed'] then
    Config.ensure_installed = options['ensure_installed']
  end
end

return {
  command = command,
  images_pull = images_pull,
  images_remove = images_remove,
  setup = setup,
  supported_languages = supported_languages
}
