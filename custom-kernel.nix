{ pkgs, linux_testing, lib, ... }:
(pkgs.linuxKernel.manualConfig rec {
  inherit (linux_testing) version src;
  modDirVersion = lib.versions.pad 3 version;
  configfile = ./configfile;
  allowImportFromDerivation = false;
}).overrideAttrs (old: {
  postPatch = old.postPatch + ''
    cp ${./arch-arm64-boot-dts-rockchip-Makefile} arch/arm64/boot/dts/rockchip/Makefile
  '';

  #postInstall = ''
  #  mkdir -p $out/lib/modules/"$version"
  #  touch  $out/lib/modules/"$version"/modules.order
  #  touch  $out/lib/modules/"$version"/modules.builtin
  #  rm $out/System.map
  #'';
  passthru = old.passthru // { features = { efiBootStub = true; }; };
})
