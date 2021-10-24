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

You can add configurations to more languages my providing an image and the command to start the container by adding following options to lspcontainers commands:

> NOTE: LspContainers makes no attempt to modify LspConfig. It is up to the end user to correctly configure LspConfig.

```lua
lspconfig.html.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = lspcontainers.command('html', {
	image = "lspcontainers/html-language-server:1.4.0",
	cmd = function (runtime, volume, image)
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
    end,
  }),
  root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
}
```

The `cmd` option of the lspcontainers config also allows modification of the command that is used to start the container for possibly mounting additional volumes or similar things.

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

### Podman Support

If you are using podman instead of docker it is sufficient to just specify "podman" as `container_runtime`:

```lua
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = lspcontainers.command('gopls', {
    container_runtime = "podman",
  }),
  root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
}
```

## Supported LSPs

Below is a list of supported language servers for configuration with `nvim-lspconfig`. Follow a link to find documentation for that config.

- [bashls](#bashls)
- [clangd](#clangd)
- [dockerls](#dockerls)
- [gopls](#gopls)
- [html](#html)
- [intelephense](#intelephense)
- [jsonls](#jsonls)
- [omnisharp](#omnisharp)
- [powershell_es](#powershell_es)
- [pylsp](#pylsp)
- [pyright](#pyright)
- [rust_analyzer](#rust_analyzer)
- [solargraph](#solargraph)
- [sumneko_lua](#sumneko_lua)
- [svelte](#svelte)
- [terraformls](#terraformls)
- [tsserver](#tsserver)
- [yamlls](#yamlls)
- [vuels](#vuels)

### bashls

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#bashls

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

### clangd

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#clangd

```lua
require'lspconfig'.clangd.setup {
  cmd = require'lspcontainers'.command('clangd'),
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

```lua
require'lspconfig'.gopls.setup {
  cmd = require'lspcontainers'.command('gopls'),
  ...
}
```

### html

```lua
require'lspconfig'.gopls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('html'),
  root_dir = util.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### intelephense

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#intelephense

```lua
require'lspconfig'.intelephense.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('intelephense'),
  root_dir = util.root_pattern("composer.json", ".git", vim.fn.getcwd()),
  ...
}
```

### jsonls

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#jsonls

```lua
require'lspconfig'.jsonls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('jsonls'),
  root_dir = util.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### omnisharp

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#omnisharp

```lua
require'lspconfig'.omnisharp.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('omnisharp'),
  root_dir = util.root_pattern("*.sln", "*.csproj", vim.fn.getcwd()),
  ...
}
```

### powershell_es

 https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#powershell_es

```lua
require'lspconfig'.powershell_es.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = require'lspcontainers'.command(server, {root_dir = new_root_dir})
  end,
  cmd = require'lspcontainers'.command(server),
  filetypes = {"ps1", "psm1", "psd1"},
  ...
}
```

### pylsp

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#pylsp

```lua
require'lspconfig'.pylsp.setup {
  cmd = require'lspcontainers'.command('pylsp'),
  ...
}
```

### pyright

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#pyright

```lua
require'lspconfig'.pyright.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('pyright'),
  root_dir = util.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### rust_analyzer

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer

```lua
require'lspconfig'.rust_analyzer.setup {
  cmd = require'lspcontainers'.command('rust_analyzer'),
  ...
}
```

### solargraph

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#solargraph

```lua
require'lspconfig'.solargraph.setup {
  cmd = require'lspcontainers'.command('solargraph'),
  ...
}
```

### sumneko_lua

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#sumneko_lua

```lua
require'lspconfig'.sumneko_lua.setup {
  cmd = require'lspcontainers'.command('sumneko_lua'),
  ...
}
```

### svelte

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#svelte

```lua
require'lspconfig'.svelte.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('svelte'),
  root_dir = util.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### terraformls

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#terraformls

```lua
require'lspconfig'.terraformls.setup {
  cmd = require'lspcontainers'.command('terraformls'),
  filetypes = { "hcl", "tf", "terraform", "tfvars" },
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

### vuels

https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#vuels

```lua
require'lspconfig'.vuels.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('vuels'),
  root_dir = util.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```
---

To contribute to LSPs, please see the [lspcontainers/dockerfiles](https://github.com/lspcontainers/dockerfiles) repository.
