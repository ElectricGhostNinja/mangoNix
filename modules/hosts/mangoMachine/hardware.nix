{ self, inputs, ... }: {
  flake.nixosModules.mangoMachineHardware = { config, lib, pkgs, modulesPath, ... }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "thunderbolt" "usbhid" "usb_storage" "uas" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/54e67a85-5455-48e9-a6c6-3b740ceb6469";
      fsType = "btrfs";
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/54e67a85-5455-48e9-a6c6-3b740ceb6469";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/54e67a85-5455-48e9-a6c6-3b740ceb6469";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/9C6A-4904";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/5d75a52c-dc17-493b-a0a2-e0c0563ae17e"; }
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
