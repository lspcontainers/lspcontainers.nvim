{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system:
        import nixpkgs {
          overlays = [ ];
          inherit system;
        });
    in {
      packages = forAllSystems (system: {
        default = pkgs.${system}.vimUtils.buildVimPluginFrom2Nix {
          name = "lspcontainers.nvim";
          src = ./.;
        };
        neovim = pkgs.${system}.neovim.override {
          configure = {
            customRC = ''
              lua << EOF
                ${(builtins.readFile ./test/init.lua)};
              EOF
            '';
            packages.main = with pkgs.${system}.vimPlugins; {
              start = [
                nvim-lspconfig
                self.packages.${system}.default
              ];
            };
          };
        };
      });

      devShells = forAllSystems (system: {
        default = pkgs.${system}.mkShellNoCC {
          buildInputs = [ self.packages.${system}.neovim ];
        };
      });

      apps = forAllSystems (system: {
        neovim = {
          program = "${self.packages.${system}.neovim}/bin/nvim";
          type = "app";
        };
      });
    };
}
