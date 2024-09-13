let
  user = import ./user.nix;
in
{
  home.username = user.name;
  home.homeDirectory = user.homeDir;
  home.stateVersion = "24.05";

  programs.direnv.enable = true;
}