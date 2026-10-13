{ self, inputs, ... }: {
  flake.nixosModules.gaming = { pkgs, lib, ... }: {
    # AMD GPU: the amdgpu kernel driver and Mesa (RADV Vulkan, RadeonSI OpenGL)
    # are what you want. They just need graphics enabled.
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # 32-bit libs, needed by Steam and many Proton games
    };
    services.xserver.videoDrivers = [ "amdgpu" ];

    # RX 9070 XT (RDNA 4) is still getting fixes in newer kernels and Mesa.
    # Mesa already comes from nixos-unstable; this pulls the newest kernel too.
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # Optional GPU control (fan curve, power limit, undervolt) with a GUI:
    # services.lact.enable = true;
    # hardware.amdgpu.overdrive.enable = true; # needed for clock/voltage tweaks

    # Steam is an X11 app, so Mango needs XWayland. This puts the Xwayland
    # binary on the system PATH, which is where Mango looks for it at runtime.
    programs.xwayland.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      # gamescopeSession.enable = true; # optional: Steam Deck-style session
    };

    # Xbox / 8BitDo controllers (X-Input mode).
    # The in-tree xpad driver handles wired 360/One pads AND 8BitDo Ultimate
    # controllers running in X-Input mode (they present the FF/5D/01 Xbox
    # interface). Load it explicitly so it is always available.
    boot.kernelModules = [ "xpad" ];

    # hardware.xone blacklists xpad and swaps in the out-of-tree xone driver.
    # That blacklist stops the 8BitDo Ultimate (X-Input) from binding, so only
    # enable xone if you actually own a genuine Microsoft Xbox wireless adapter
    # or an Elite / Elite V2 pad.
    # hardware.xone.enable = true;
    hardware.xpadneo.enable = true; # Bluetooth controllers (replaces Nobara's patched-in xpadneo)
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    programs.gamemode.enable = true; # use with: gamemoderun %command%

    environment.systemPackages = [
      pkgs.protonplus # GUI for installing Proton-GE and other compat tools
      pkgs.gamescope  # Wayland/XWayland compositor for games
    ];

    # Optional: Steam UI scaling (uncomment if the UI looks too small on HiDPI)
    # environment.sessionVariables.STEAM_FORCE_DESKTOPUI_SCALING = "1";
  };
}
