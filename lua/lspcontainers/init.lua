local function command(server)
  local cwd = vim.fn.getcwd()
  local image = ""
  local volume = cwd..":"..cwd

  -- TODO: dockerfile exists, needs implementation
  --if server == "dockerls" then
    --image = "lspcontainers/docker-langserver:0.4.1"
  --end

  if server == "sumneko_lua" then
    image = "lspcontainers/lua-language-server:1.20.5"
  end

  if image == "" then
    error("Invalid language server provided")
  end

  return {
      "docker",
      "container",
      "run",
      "--interactive",
      "--rm",
      "--volume",
      volume,
      image
    }
end

return {
  command = command
}
