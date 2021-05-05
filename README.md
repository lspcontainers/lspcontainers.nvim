# lspcontainers.nvim

Neovim plugin for lspcontainers.

## Overview

The goal of this plugin is to provide simple setup for running language servers in Docker containers integrated into Neovim. This plugin expects the same LSP names from `neovim/nvim-lspconfig`.

## Installation

1. Install the plugin via your package manager of choice:
  a. via `plug` manager
```
Plug 'neovim/nvim-lspconfig'
Plug 'lspcontainers/lspcontainers.nvim'
```
  b. via `packer` manager
```
use 'neovim/nvim-lspconfig'
use {
  'lspcontainers/lspcontainers.nvim',
  requires = { 'neovim/nvim-lspconfig' }
}
```

2. Setup `lspconfig` and replace `command` option

```
local server = "sumneko_lua"
require'lspconfig'[server].setup{ command = require'lspcontainers'.command(server) }
```
