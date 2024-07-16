_default:
    just --list

build profile="default":
    nix build --json --no-link --print-build-logs ".#{{ profile }}"

check:
    nix flake check

test: test-lint test-unit

test-lint:
    luacheck ./lua ./test

test-unit:
    #!/usr/bin/env bash
    set -euxo pipefail
    export VUSTED_NVIM=$(just build 'neovim' | jq -r '.[].outputs.out')/bin/nvim
    vusted ./test
