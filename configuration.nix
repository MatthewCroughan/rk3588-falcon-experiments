{ modulesPath, lib, pkgs, ... }:
{
  imports = [
    ./repart.nix
    "${modulesPath}/profiles/perlless.nix"
    "${modulesPath}/profiles/minimal.nix"
    ./rk3588.nix
  ];
  boot.loader.systemd-boot = {
    enable = true;
  };
  users.users.root.password = "default";
  services.userborn.enable = lib.mkForce true;
  systemd.sysusers.enable = lib.mkForce false;
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
#  boot.kernelPackages = pkgs.linuxPackages_latest;
}
