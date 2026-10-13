{ self, inputs, ... }: {
  flake.nixosModules.cliTools = { pkgs, lib, ... }: {
    environment.systemPackages = with pkgs; [
      opencode
      qbittorrent
      superfile
      gnome-disk-utility
      starship
      ripgrep
      fzf
      fd
      fastfetch
    ];
  };
}
