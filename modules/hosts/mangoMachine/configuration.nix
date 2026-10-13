{ self, inputs, ... }: {
  flake.nixosModules.mangoMachineConfiguration = { config, pkgs, lib, ... }: {
    imports = [
      self.nixosModules.mangoMachineHardware
      self.nixosModules.mango
      self.nixosModules.gaming
      self.nixosModules.cliTools
      self.nixosModules.ssh
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";
    networking.networkmanager.enable = true;

    # Udisks2 creates /run/media/$USER as root:root, so ghost can't write at
    # that level. Take ownership of the removable-media dir on boot.
    systemd.tmpfiles.rules = [
      "d /run/media/ghost 0755 ghost users -"
    ];

    time.timeZone = "America/Los_Angeles";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # KDE Plasma stays enabled as a fallback session while you set up mango.
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.printing.enable = true;

    # Sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    users.users."ghost" = {
      isNormalUser = true;
      description = "Ghost Ninja";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        kdePackages.kate
        thunderbird
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWDyDjc9ZtLMDi51EuoXLu4rUWNTtoWORscJGvxXyFR electricghostninja@tuta.io"
      ];
    };

    programs.firefox.enable = true;
    nixpkgs.config.allowUnfree = true;

    # Nix package only ships the `superfile` binary; upstream docs use `spf`.
    environment.shellAliases.spf = "superfile";

    environment.systemPackages = with pkgs; [
      emacs
      ghostty
      qbittorrent
      zsh
      wget
      git
    ];

    services.openssh.enable = true;

    programs.kdeconnect.enable = true;

    networking.firewall = {
      enable = true;
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };

    # Do NOT change this after the initial install.
    system.stateVersion = "26.05";
  };
}
