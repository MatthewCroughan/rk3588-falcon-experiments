{ lib, pkgs, inputs, ... }:
{
  nixpkgs.hostPlatform = lib.mkForce (inputs.nixpkgs.lib.recursiveUpdate (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-musl") {
    linux-kernel = {
      name = "aarch64-multiplatform";
      baseConfig = "tinyconfig";
      DTB = true;
      extraConfig = "";
      autoModules = false;
      preferBuiltin = true;
      target = "vmlinuz.efi";
      installTarget = "zinstall";
    };
    useLLVM = true;
    linker = "lld";
    config = "aarch64-unknown-linux-musl";
  });

  boot.kernelPatches = [
    {
      name = "config-enable-zboot";
      patch = null;
      structuredExtraConfig = {
        EFI_ZBOOT = lib.mkForce lib.kernel.yes;
        KERNEL_ZSTD = lib.mkForce lib.kernel.yes;
        RD_ZSTD = lib.mkForce lib.kernel.yes;
      };
    }
    {
      name = "config-builtin-mmc";
      patch = null;
      structuredExtraConfig = {
        MMC = lib.mkForce lib.kernel.yes;
        EROFS_FS_ZIP_ZSTD = lib.mkForce lib.kernel.yes;
      };
    }
    {
      name = "only-needed-for-collabora";
      patch = null;
      structuredExtraConfig = {
        DRM_NOUVEAU_GSP_DEFAULT = lib.mkForce lib.kernel.unset;
        EXT3_FS_POSIX_ACL = lib.mkForce lib.kernel.unset;
        EXT3_FS_SECURITY = lib.mkForce lib.kernel.unset;
        ZPOOL = lib.mkForce lib.kernel.unset;
        HID_MULTITOUCH = lib.mkForce lib.kernel.no;
      };
    }
  ];

  ## We use a builtins based kernel with no modules anyway
  #boot.initrd.availableKernelModules = lib.mkForce [ ];
  #boot.kernelModules = lib.mkForce [ ];
  #boot.initrd.kernelModules = lib.mkForce [ ];
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./custom-kernel.nix { });
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./collabora-kernel.nix { });
}
