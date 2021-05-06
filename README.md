# lspcontainers.nvim

Neovim plugin for lspcontainers - developed weekly live at [The Alt-F4 Stream](https://www.twitch.tv/thealtf4stream "The Alt-F4 Stream") on Twitch.

> IMPORTANT: everything below is a work-in-progress and subject to change at any time

## Overview

Provide a simple method for running language servers in Docker containers using `neovim/nvim-lspconfig`. This plugin expects the same language server names from `neovim/nvim-lspconfig`. See [neovim/nvim-lspconfig/CONFIG.md](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md) for a complete list of servers.

## Installation

1. Install plugins via your package manager of choice

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

2. Setup `lspconfig` and replace `command` option

```lua
local server = "sumneko_lua"
require'lspconfig'[server].setup{ cmd = require'lspcontainers'.command(server) }
```

To sync up the volume mount with the lspconfig's `root_dir`, use `on_new_config`
```lua
local server = "sumneko_lua"
require'lspconfig'[server].setup{
  on_new_config = function(new_config, new_root_dir)
    new_config.cmd = require'lspcontainers'.command(server, { root_dir = new_root_dir })
  end
}
```

## Supported LSPs

Below is a list of supported language servers for configuration with `nvim-lspconfig`.

> NOTE: Any unchecked language servers are planned to be implemented.

- [ ] als
- [ ] angularls
- [ ] bashls
- [ ] beancount
- [ ] ccls
- [ ] clangd
- [ ] clojure_lsp 
- [ ] cmake
- [ ] codeqlls
- [ ] cssls
- [ ] dartls
- [ ] denols
- [ ] dhall_lsp_server
- [ ] diagnosticls
- [ ] dockerls
- [ ] dotls
- [ ] efm
- [ ] elixirls
- [ ] elmls
- [ ] erlangls
- [ ] flow
- [ ] fortls
- [ ] fsautocomplete
- [ ] gdscript
- [ ] ghcide
- [ ] gopls
- [ ] graphql
- [ ] groovyls
- [ ] haxe_language_server
- [ ] hie
- [ ] hls
- [ ] html
- [ ] intelephense
- [ ] jdtls
- [ ] jedi_language_server
- [ ] jsonls
- [ ] julials
- [ ] kotlin_language_server
- [ ] leanls
- [ ] metals
- [ ] nimls
- [ ] ocamlls
- [ ] ocamllsp
- [ ] omnisharp
- [ ] perlls
- [ ] phpactor
- [ ] powershell_es
- [ ] purescriptls
- [ ] pyls
- [ ] pyls_ms
- [ ] pyright
- [ ] r_language_server
- [ ] racket_langserver
- [ ] rls
- [ ] rnix
- [ ] rome
- [ ] rust_analyzer
- [ ] scry
- [ ] solargraph
- [ ] sorbet
- [ ] sourcekit
- [ ] sqlls
- [ ] sqls
- [ ] stylelint_lsp
- [x] sumneko_lua
- [ ] svelte
- [ ] svls
- [ ] terraformls
- [ ] texlab
- [ ] tflint
- [ ] tsserver
- [ ] vala_ls
- [ ] vimls
- [ ] vls
- [ ] vuels
- [ ] yamlls
- [ ] zls

To add more LSPs, please see the [lspcontainers/dockerfiles](https://github.com/lspcontainers/dockerfiles) repository.
