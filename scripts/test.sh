#!/usr/bin/env bash

set -euo 'pipefail'

parent_git_dir=$(git rev-parse --show-toplevel)
cd "${parent_git_dir}"

if [ ! -d nvim-lspconfig ]; then
  git clone --depth=1 https://github.com/neovim/nvim-lspconfig/
fi

exec nvim -u NONE -E -R --headless +"set rtp+=$PWD" +"set rtp+=nvim-lspconfig" +'luafile scripts/test.lua' +q
# nvim -u scripts/test_keys.lua
