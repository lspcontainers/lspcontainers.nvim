# lspcontainers.nvim

Neovim plugin for lspcontainers - developed weekly live at [The Alt-F4 Stream](https://www.twitch.tv/thealtf4stream "The Alt-F4 Stream") on Twitch.

> IMPORTANT: everything below is a work-in-progress and subject to change at any time

## Overview

Provide a simple method for running language servers in Docker containers using `neovim/nvim-lspconfig`. This plugin expects the same language server names from `neovim/nvim-lspconfig`. See [neovim/nvim-lspconfig/CONFIG.md](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md) for a complete list of servers.

## Installation

1. Install latest [Docker Engine](https://docs.docker.com/engine/install/) for your operating system

2. Install `lspconfig` and `lspcontainers` via package manager

- via `packer` manager
  
  ```lua
  use 'neovim/nvim-lspconfig'
  use 'lspcontainers/lspcontainers.nvim'
  ```

- via `plug` manager
  
  ```vim
  Plug 'neovim/nvim-lspconfig'
  Plug 'lspcontainers/lspcontainers.nvim'
  ```

3. Setup the language of your choice from [Supported LSPs](#supported-lsps)

## Advanced Configuration

### Additional Languages

You can add the default LSPs through the `additional_languages` shown below:

> NOTE: LspContainers makes no attempt to modify LspConfig. It is up to the end user to correctly configure LspConfig.

```lua
require'lspcontainers'.command("lua", {
  additional_languages = {
    lua = "lspcontainers/lua-language-server:1.20.5"
  }
})
```

### Volume Syncing

In some circumstances a language server may need the `root_dir` path synced with the Docker container. To sync up the volume mount with the lspconfig's `root_dir`, use `on_new_config`:

```lua
local server = "sumneko_lua"
require'lspconfig'[server].setup{
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = require'lspcontainers'.command(server, { root_dir = new_root_dir })
  end
}
```

## Supported LSPs

Below is a list of supported language servers for configuration with `nvim-lspconfig`. Follow a link to find documentation for that config.

- [bashls](#bashls)
- [dockerls](#dockerls)
- [gopls](#gopls)
- [sumneko_lua](#sumneko_lua)
- [tsserver](#tsserver)
- [yamlls](#yamlls)

### bashls

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#bashls

Language server for bash, written using tree sitter in typescript.

```lua
require'lspconfig'.bashls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('bashls'),
  root_dir = util.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### dockerls

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#dockerls

```lua
require'lspconfig'.dockerls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('dockerls'),
  root_dir = util.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### gopls

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#gopls

Google's lsp server for golang.

```lua
require'lspconfig'.gopls.setup {
  cmd = require'lspcontainers'.command('gopls'),
  ...
}
```

### sumneko_lua

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#sumneko_lua

Lua language server.

```lua
require'lspconfig'.sumneko_lua.setup {
  cmd = require'lspcontainers'.command('sumneko_lua'),
  ...
}
```

### tsserver

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#tsserver

```lua
require'lspconfig'.tsserver.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('tsserver'),
  root_dir = util.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### yamlls

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#yamlls

Language server for bash, written using tree sitter in typescript.

```lua
require'lspconfig'.yamlls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('yamlls'),
  root_dir = util.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

---

To contribute to LSPs, please see the [lspcontainers/dockerfiles](https://github.com/lspcontainers/dockerfiles) repository.
