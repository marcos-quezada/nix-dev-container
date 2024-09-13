{
  description = "Home Manager configuration";

  inputs = {
    # Package sets
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    nixpkgs-unstable.url = "github:NixOs/nixpkgs/nixos-unstable";

    # Environment/system management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    #Flake utils
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, home-manager, nixpkgs-unstable, ... }:
    let
      utils = flake-utils;
      user = import ./user.nix;
    in
    utils.lib.eachDefaultSystem (system:
      let
        stable-pkgs = nixpkgs.legacyPackages.${system};
        unstable-pkgs = nixpkgs-unstable.legacyPackages.${system};
        pkgs = stable-pkgs // {
          # provides alias for all ustable pkgs
          unstable = unstable-pkgs;

          starship = unstable-pkgs.starship;
          git = unstable-pkgs.git;
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        packages = {
          homeConfigurations.${user.name} = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            # Specify your home configuration modules here, for example,
            # the path to your home.nix.
            modules = [
              ./home.nix
            ];

            # Optionally use extraSpecialArgs
            # to pass through arguments to home.nix
            extraSpecialArgs = {
              inherit pkgs;
            };
          };
        };
      });
}