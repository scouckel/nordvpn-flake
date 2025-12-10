{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { nixpkgs, ... }: 
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        nordvpn = pkgs.callPackage ./nordvpn.nix { };
      });

      nixosModules.nordvpn-flake = import ./module.nix;

      defaultPackage = forAllSystems (pkgs: pkgs.callPackage .nordvpn.nix { });
    };
}
