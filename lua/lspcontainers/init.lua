-- default command to run the lsp container
local default_cmd = function (runtime, volume, image)
  return {
    runtime,
    "container",
    "run",
    "--interactive",
    "--rm",
    "--volume",
    volume,
    image
  }
end

local supported_languages = {
  bashls = { image = "lspcontainers/bash-language-server:1.17.0", cmd = default_cmd },
  clangd = { image = "lspcontainers/clangd-language-server:11.1.0", cmd = default_cmd },
  dockerls = { image = "lspcontainers/docker-language-server:0.4.1", cmd = default_cmd },
  jsonls = { image = "lspcontainers/json-language-server:1.3.4", cmd = default_cmd },
  gopls = { image = "lspcontainers/gopls:0.6.11", cmd = default_cmd },
  html = { image = "lspcontainers/html-language-server:1.4.0", cmd = default_cmd },
  pylsp = { image = "lspcontainers/python-lsp-server:1.1.0", cmd = default_cmd },
  pyright = { image = "lspcontainers/pyright-langserver:1.1.137", cmd = default_cmd },
  rust_analyzer = { image = "lspcontainers/rust-analyzer:2021-05-03", cmd = default_cmd },
  svelte = { image = "lspcontainers/svelte-language-server:0.14.3", cmd = default_cmd },
  terraformls = { image = "lspcontainers/terraform-ls:0.19.1", cmd = default_cmd },
  sumneko_lua = { image = "lspcontainers/lua-language-server:1.20.5", cmd = default_cmd },
  tsserver = { image = "lspcontainers/typescript-language-server:0.5.1", cmd = default_cmd },
  yamlls = { image = "lspcontainers/yaml-language-server:0.18.0", cmd = default_cmd },
  vuels = { image = "lspcontainers/vue-language-server:0.7.2", cmd = default_cmd },
  intelephense = { image = "lspcontainers/intelephense:1.7.1", cmd = default_cmd }
}

local function command(server, user_opts)
  local opts = user_opts or {}

  local workdir = opts.root_dir or vim.fn.getcwd()
  local volume = workdir..":"..workdir..":ro"

  local additional_languages = opts.additional_languages or {}
  local image = nil
  local cmd_builder = nil
  if additional_languages[server] then
    image = additional_languages[server].image
	cmd_builder = additional_languages[server].cmd
  else
    image = supported_languages[server].image
	cmd_builder = supported_languages[server].cmd
  end
  local runtime = opts.container_runtime or "docker"

  if not image then
    error(string.format("lspcontainers: language not supported `%s`", server))
    return 1
  end

  return cmd_builder(runtime, volume, image)
end

return {
  command = command,
  supported_languages = supported_languages
}
