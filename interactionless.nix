# Further minimization, at the cost of being able to interact with the system by any means
{ lib, ... }:
{
  # Maybe in the end..
  environment.systemPackages = lib.mkForce [ ];
  # Can save 1MB by disabling console
  console.enable = false;
  boot.initrd.systemd.extraBin = lib.mkForce {};
}
