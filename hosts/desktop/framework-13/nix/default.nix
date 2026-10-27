{
  config,
  lib,
  pkgs,
  ar_dir,
  ...
}:

{
  imports = [
    ./no-airplane-mode-switch/default.nix
    "${ar_dir}/modules/nixos-desktop/nixos/default.nix"
    "${ar_dir}/modules/no-yubikey-keyboard/default.nix"
  ];

  networking.hostName = "framework-13";

  # Initial state. Don't change this
  system.stateVersion = "26.05"; 

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  services.fwupd.enable = true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot = {
    loader.systemd-boot.extraEntries = {
      "fedoragrub.conf" = ''
        title Fedora Grub
        efi /EFI/fedora/grubx64.efi
      '';
    };
    
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
      luks.devices."luks--fcaa015b-b33e-44cd-ad40-3380632eb3b9".device =
        "/dev/disk/by-uuid/fcaa015b-b33e-44cd-ad40-3380632eb3b9";
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/luks--fcaa015b-b33e-44cd-ad40-3380632eb3b9";
      fsType = "btrfs";
      options = [ "subvol=nixos-root,compress=zstd,ssd,noatime,discard" ];
    };

    "/fedora-root" = {
      device = "/dev/mapper/luks--fcaa015b-b33e-44cd-ad40-3380632eb3b9";
      fsType = "btrfs";
      options = [ "subvol=fedora-root,compress=zstd,ssd,noatime,discard" ];
    };

    "/home" = {
      device = "/dev/mapper/luks--fcaa015b-b33e-44cd-ad40-3380632eb3b9";
      fsType = "btrfs";
      options = [ "subvol=home,compress=zstd,ssd,noatime,discard" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/C4BA-9A96";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
