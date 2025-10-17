{ modulesPath, lib, pkgs, ... }:
{
  imports = [
#    "${modulesPath}/profiles/perlless.nix"
#    "${modulesPath}/profiles/minimal.nix"
    ./repart.nix
    ./rk3588.nix
    ./io-board
    ./bullshit.nix
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
