{ modulesPath, pkgs, config, lib, ... }:
let
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in
{
  imports = [ "${modulesPath}/image/repart.nix" ];
  boot.loader.grub.enable = false;
  boot.loader.timeout = 0;

  # Probably necessary for root resize
  systemd.repart.enable = lib.mkDefault true;
  systemd.repart.partitions."store".Type = "root";
  boot.initrd.systemd.enable = true;
#  boot.initrd.systemd.root = "gpt-auto";
#  boot.initrd.supportedFilesystems.erofs = true;
  fileSystems."/nix/store" =
    let
      partConf = config.image.repart.partitions."store".repartConfig;
    in
    {
      device = "/dev/disk/by-partlabel/${partConf.Label}";
      fsType = partConf.Format;
    };
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };

  #fileSystems."/".device = "/dev/disk/by-label/nixos";
  #fileSystems."/".fsType = "erofs";
  #fileSystems."/boot".device = "/dev/disk/by-label/ESP";
  #fileSystems."/boot".fsType = "vfat";
  boot.initrd.systemd.initrdBin = [ pkgs.erofs-utils ];
  image.repart = {
    name = "image";
    package = pkgs.buildPackages.systemdMinimal.override { withEfi = true; withBootloader = true; withRepart = true; withCryptsetup = true; };
    compression.enable = true;
    partitions = {
      "10-uboot-padding" = {
        repartConfig = {
          Type = "linux-generic";
          Label = "uboot-padding";
          SizeMinBytes = "10M";
        };
      };
      "20-esp" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
          "/EFI/Linux/${config.system.boot.loader.ukiFile}".source = "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
          "/loader/loader.conf".source = pkgs.writeText "loader.conf" ''
            timeout 0
            console-mode keep
          '';
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          Label = "ESP";
          SizeMinBytes = "500M";
          GrowFileSystem = true;
        };
      };
      "store" = {
        storePaths = [ config.system.build.toplevel ];
        stripNixStorePrefix = true;
        repartConfig = {
          Type = "linux-generic";
          Label = "store";
          Format = "erofs";
          Compression = "zstd";
          Minimize = "best";
          ReadOnly = "yes";
          SplitName = "store";
        };
      };

#      "30-root" = {
#        storePaths = [ config.system.build.toplevel ];
#        contents."/boot".source = pkgs.runCommand "boot" { } "mkdir $out";
#        repartConfig = {
#          Type = "linux-generic";
#          Format = "erofs";
#          Label = "nixos";
#          Compression = "zstd";
#          Minimize = "best";
#          ReadOnly = "yes";
#        };
#        #repartConfig = {
#        #  Type = "root";
#        #  Format = "ext4";
#        #  Label = "nixos";
#        #  Minimize = "guess";
#        #  GrowFileSystem = true;
#        #};
#      };
    };
  };
}


