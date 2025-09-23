{ lib, pkgs, ... }:
{
#  boot.kernelPatches = [
#    {
#      name = "config-builtin-mmc";
#      patch = null;
#      structuredExtraConfig = {
#        MMC = lib.mkForce lib.kernel.yes;
#      };
#    }
#  ];

  # We use a builtins based kernel with no modules anyway
  boot.initrd.availableKernelModules = lib.mkForce [ ];
  boot.kernelModules = lib.mkForce [ ];
  boot.initrd.kernelModules = lib.mkForce [ ];
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./custom-kernel.nix { });
}
