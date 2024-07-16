{
  description = "lspcontainers.nvim";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        inherit (pkgs) just luajitPackages mkShell neovim vimPlugins vimUtils writeShellApplication;
        inherit (luajitPackages) luacheck vusted;
      in {
        packages = {
          default = vimUtils.buildVimPlugin {
            name = "lspcontainers.nvim";
            src = ./.;
          };

          neovim = neovim.override {
            configure = {
              customRC = ''
                lua << EOF
                  ${(builtins.readFile ./init.lua)};
                EOF
              '';
              packages.main = with vimPlugins; {
                start = [
                  nvim-lspconfig
                  config.packages.default
                ];
              };
            };
          };
        };

        devShells = {
          default = mkShell {
            nativeBuildInputs = [just luacheck vusted];
          };
        };

        apps = {
          neovim = {
            program = "${config.packages.neovim}/bin/nvim";
            type = "app";
          };

          test = {
            program = "${config.packages.test}/bin/test";
            type = "app";
          };
        };
      };
    };
}
