# Further minimization, at the cost of being able to interact with the system by any means
{ lib, pkgs, ... }:
{
#  imports = [
#    ./bashless.nix
#  ];
  # Maybe in the end..

  environment.etc."shells".enable = false;
  boot.initrd.systemd.users.nobody.shell = "/bin/sh";
  boot.initrd.systemd.suppressedStorePaths = [ "${pkgs.shadow}/bin/nologin" ];
  environment.systemPackages = lib.mkForce [ ];
  # Can save 1MB by disabling console
  console.enable = false;
  boot.initrd.systemd.extraBin = lib.mkForce {};
  security.pam.package = lib.mkForce (pkgs.runCommandNoCC "neutered" { } "mkdir -p $out");
  systemd.globalEnvironment.TZDIR = lib.mkForce "";
  environment.etc.zoneinfo.source = lib.mkForce (pkgs.runCommandNoCC "neutered" { } "mkdir -p $out");
  security.pam.services = lib.mkForce {};
  services.udev.packages = lib.mkForce [];
  security.enableWrappers = lib.mkForce false;
  environment.binsh = null;
  nixpkgs.overlays = [
    (self: super: {
      util-linuxMinimal = super.util-linux.override {
        fetchurl = super.stdenv.fetchurlBoot;
        cryptsetupSupport = false;
        nlsSupport = false;
        ncursesSupport = false;
        pamSupport = false;
        shadowSupport = false;
        systemdSupport = false;
        translateManpages = false;
        withLastlog = false;
      };
      util-linux = super.util-linux.override {
        fetchurl = super.stdenv.fetchurlBoot;
        cryptsetupSupport = false;
        nlsSupport = false;
        ncursesSupport = false;
        pamSupport = false;
        shadowSupport = false;
        systemdSupport = false;
        translateManpages = false;
        withLastlog = false;
      };
    })
  ];
}
