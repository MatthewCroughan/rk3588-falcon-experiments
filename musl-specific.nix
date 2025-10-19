{ pkgs, lib, ... }:
let
  glibcPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; });
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in
{
  nixpkgs.overlays = [
    (self: super: {
      systemdUkify = self.systemd.override {
        withUkify = true;
        withBootloader = true;
        withEfi = true;
        withAudit = false;
      };
    })
  ];
  image.repart.partitions."20-esp".contents."/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = lib.mkForce  "${glibcPkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
  boot.uki.settings.UKI.Stub =
    "${glibcPkgs.systemd}/lib/systemd/boot/efi/linux${pkgs.stdenv.hostPlatform.efiArch}.efi.stub";
}
