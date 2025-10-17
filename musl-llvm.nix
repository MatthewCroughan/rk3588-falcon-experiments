{ pkgs, lib, ... }:
let
  glibcPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; });
in
{
  imports = [
    ./musl.nix
  ];
  system = {
    switch.enable = lib.mkForce false;
    disableInstallerTools = lib.mkForce false;
    tools.nixos-option.enable = lib.mkForce false;
  };
  services.dbus.implementation = "broker";
  boot.loader.systemd-boot.enable = lib.mkForce false;
  nix.enable = lib.mkForce false;
  nixpkgs.overlays = [
    (self: super: {
      # Prevents accidental runtime linkage to llvm bintools
      gnugrep = super.gnugrep.override { runtimeShellPackage = self.runCommandNoCC "neutered" { } "mkdir -p $out"; };
      dbus = super.dbus.overrideAttrs (old: { configureFlags = old.configureFlags ++ [ "--disable-libaudit" "--disable-apparmor" ]; });
      libcap = super.libcap.override { withGo = false; };
      netbsd = super.netbsd.overrideScope (
        _final: prev: {
          compat = prev.compat.overrideAttrs (old: { makeFlags = old.makeFlags ++ [ "OBJCOPY=${glibcPkgs.binutils}/bin/strip" ]; });
        }
      );
      pam = super.pam.overrideAttrs {
        NIX_LDFLAGS = lib.optionalString (super.stdenv.cc.bintools.isLLVM && lib.versionAtLeast super.stdenv.cc.bintools.version "17") "--undefined-version";
      };
    })
  ];
}
