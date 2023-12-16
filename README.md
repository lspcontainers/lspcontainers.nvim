# lspcontainers.nvim

Neovim plugin for lspcontainers - developed weekly live at [The Alt-F4 Stream](https://www.twitch.tv/thealtf4stream "The Alt-F4 Stream") on Twitch.

> IMPORTANT: everything below is a work-in-progress and subject to change at any time

## Overview

Provide a simple method for running language servers in Docker containers using `neovim/nvim-lspconfig`. This plugin expects the same language server names from `neovim/nvim-lspconfig`. See [neovim/nvim-lspconfig/doc/server_configurations.md](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) for a complete list of servers.

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

You can add configurations to more languages by providing an image and the command to start the container by adding the following options to lspcontainers commands:

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
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
}
```

The `cmd` option of the lspcontainers config also allows modification of the command that is used to start the container for possibly mounting additional volumes or similar things.

### Volume Syncing

In some circumstances a language server may need the `root_dir` path synced with the Docker container. To sync up the volume mount with the lspconfig's `root_dir`, use `on_new_config`:

```lua
local server = "lua_ls"
require'lspconfig'[server].setup{
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = require'lspcontainers'.command(server, { root_dir = new_root_dir })
  end
}
```

### Volume Mount

You can either mount a path on host or a docker volume

#### Mount Persistent volume
You can [create a volume](https://docs.docker.com/engine/reference/commandline/volume_create/) (docker_volume) and mount it at path (workdir).

```bash
docker create volume persistent_volume_projects
```

```lua
require'lspconfig'.omnisharp.setup {
  capabilities = capabilities,
  before_init = before_init_process_id_nil,
  cmd = require'lspcontainers'.command(
      'omnisharp',
      {
          workdir = /projects
          docker_volume = 'persistent_volume_projects',
      }
  ),
  on_new_config = on_new_config,
  on_attach = on_attach,
  root_dir = require'lspconfig/util'.root_pattern("*.sln", vim.fn.getcwd()),
}
```

#### Mount Volume from Host

You can mount a volume from your host by just assigning workdir to match the host path.

```lua
require'lspconfig'.omnisharp.setup {
  capabilities = capabilities,
  before_init = before_init_process_id_nil,
  cmd = require'lspcontainers'.command(
      'omnisharp',
      {
          workdir = /home/[UserName]/projects
      }
  ),
  on_new_config = on_new_config,
  on_attach = on_attach,
  root_dir = require'lspconfig/util'.root_pattern("*.sln", vim.fn.getcwd()),
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
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
}
```

### Network support

By default, LSPs that don't require network access run with `network=none`.
This means the container has no network access. If you have a special case
where an LSP needs network access, you can specify this explicitly:

```lua
cmd = lspcontainers.command('mylsp', {
  -- ...
  network = "bridge",
}),
```

If you find that an LSP that commonly requires network access doesn't have this
by default, please open a PR updating its default (see `init.lua`).

## Process Id

The LSP spec allows a client to send its process id to a language server, so
that the server can exit immediately when it detects that the client is no
longer running.

This feature fails to work properly no a containerized language server because
the host and the container do not share the container namespace by default.

A container can share a process namespace with the host by passing the
`--pid=host` flag to docker/podman, although it should be noted that this
somewhat reduces isolation.

It is also possible to simply disable the process id detection. This can be
done with the following `before_init` function:

```
require'lspconfig'.bashls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('bashls'),
}
```

This is **required** for several LSPs, and they will exit immediately if this is
not specified.

## Supported LSPs

Below is a list of supported language servers for configuration with `nvim-lspconfig`. Follow a link to find documentation for that config.

- [bashls](#bashls)
- [clangd](#clangd)
- [denols](#denols)
- [dockerls](#dockerls)
- [gopls](#gopls)
- [graphql](#graphql)
- [html](#html)
- [intelephense](#intelephense)
- [jsonls](#jsonls)
- [omnisharp](#omnisharp)
- [powershell_es](#powershell_es)
- [prismals](#prismals)
- [pylsp](#pylsp)
- [pyright](#pyright)
- [rust_analyzer](#rust_analyzer)
- [solargraph](#solargraph)
- [lua_ls](lua_ls)
- [svelte](#svelte)
- [tailwindcss](#tailwindcss)
- [terraformls](#terraformls)
- [tsserver](#tsserver)
- [vuels](#vuels)
- [yamlls](#yamlls)

### bashls

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#bashls

```lua
require'lspconfig'.bashls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('bashls'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### clangd

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#clangd

```lua
require'lspconfig'.clangd.setup {
  cmd = require'lspcontainers'.command('clangd'),
  ...
}
```

### denols

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#denols

```lua
require'lspconfig'.denols.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('denols'),
  root_dir = require'lspconfig/util'.root_pattern("deno.json", vim.fn.getcwd()),
  ...
}
```

### dockerls

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#dockerls

```lua
require'lspconfig'.dockerls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('dockerls'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### gopls

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls

```lua
require'lspconfig'.gopls.setup {
  cmd = require'lspcontainers'.command('gopls'),
  ...
}
```

### graphql

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#graphql

```lua
require'lspconfig'.graphql.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('graphql'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### html

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html

```lua
require'lspconfig'.html.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('html'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### intelephense

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#intelephense

```lua
require'lspconfig'.intelephense.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('intelephense'),
  root_dir = require'lspconfig/util'.root_pattern("composer.json", ".git", vim.fn.getcwd()),
  ...
}
```

### jsonls

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls

```lua
require'lspconfig'.jsonls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('jsonls'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### omnisharp

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp

```lua
require'lspconfig'.omnisharp.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('omnisharp'),
  root_dir = require'lspconfig/util'.root_pattern("*.sln", "*.csproj", vim.fn.getcwd()),
  ...
}
```

### powershell_es

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#powershell_es

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

### prismals

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#prismals

```lua
require'lspconfig'.prismals.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('prismals'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### pylsp

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pylsp

```lua
require'lspconfig'.pylsp.setup {
  cmd = require'lspcontainers'.command('pylsp'),
  ...
}
```

### pyright

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pyright

```lua
require'lspconfig'.pyright.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('pyright'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### rust_analyzer

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer

```lua
require'lspconfig'.rust_analyzer.setup {
  cmd = require'lspcontainers'.command('rust_analyzer'),
  ...
}
```

### solargraph

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#solargraph

```lua
require'lspconfig'.solargraph.setup {
  cmd = require'lspcontainers'.command('solargraph'),
  ...
}
```

### lua_ls

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls

```lua
require'lspconfig'.lua_ls.setup {
  cmd = require'lspcontainers'.command('lua_ls'),
  ...
}
```

### svelte

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#svelte

```lua
require'lspconfig'.svelte.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('svelte'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### tailwindcss

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tailwindcss

```lua
require'lspconfig'.tailwindcss.setup {
  before_init = function(params)
  	params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('tailwindcss'),
  filetypes = { "django-html", "htmldjango", "gohtml", "html", "markdown", "php", "css", "postcss", "sass", "scss", "stylus", "javascript", "javascriptreact", "rescript", "typescript", "typescriptreact", "vue", "svelte" },
  root_dir = require'lspconfig/util'.root_pattern("tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "postcss.config.ts", "package.json", "node_modules", ".git", vim.fn.getcwd()),
  ...
}
```

### terraformls

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#terraformls

```lua
require'lspconfig'.terraformls.setup {
  cmd = require'lspcontainers'.command('terraformls'),
  filetypes = { "hcl", "tf", "terraform", "tfvars" },
  ...
}
```

### tsserver

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver

```lua
require'lspconfig'.tsserver.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('tsserver'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### yamlls

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#yamlls

```lua
require'lspconfig'.yamlls.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('yamlls'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

### vuels

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#vuels

```lua
require'lspconfig'.vuels.setup {
  before_init = function(params)
    params.processId = vim.NIL
  end,
  cmd = require'lspcontainers'.command('vuels'),
  root_dir = require'lspconfig/util'.root_pattern(".git", vim.fn.getcwd()),
  ...
}
```

---

To contribute to LSPs, please see the [lspcontainers/dockerfiles](https://github.com/lspcontainers/dockerfiles) repository.
