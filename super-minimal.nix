{
  modulesPath,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/perlless.nix"
    "${modulesPath}/profiles/minimal.nix"
  ];
  networking.dhcpcd.enable = false;
  fonts.fontconfig.enable = false;
  environment.etc."udev/hwdb.bin".enable = false;
  services.timesyncd.enable = false;
  systemd.oomd.enable = false;
  networking.wireless.enable = false;

  systemd.network.enable = false;
  networking.useNetworkd = false;
  services.resolved.enable = false;
  services.openssh.enable = lib.mkForce false;
  networking.useDHCP = false;

  # Complains about lastlog
  systemd.tmpfiles.packages = lib.mkForce [ ];

  # https://github.com/NixOS/nixpkgs/issues/404169
  security.pam.services.login.rules.session.lastlog.enable = lib.mkForce false;

  programs.nano.enable = false;
  security.polkit.enable = lib.mkForce false;
  programs.ssh.package = pkgs.runCommandNoCC "neutered" { } "mkdir -p $out";
  systemd.tpm2.enable = false;
  security.sudo.enable = false;
  services.lvm.enable = false;
  boot.bcache.enable = false;
  powerManagement.enable = false;

#  # We use a builtins based kernel with no modules anyway
#  boot.initrd.availableKernelModules = lib.mkForce [ ];
#  boot.kernelModules = lib.mkForce [ ];
#  boot.initrd.kernelModules = lib.mkForce [ ];

  # Maybe in the end..
  # environment.systemPackages = lib.mkForce [ ];

  # Can save 1MB by disabling console
  # console.enable = false;

  boot.hardwareScan = false;

  boot.enableContainers = false;
  networking.resolvconf.enable = false;

  nixpkgs.overlays = [
    (self: super: {
      util-linux = super.util-linux.override {
        systemdSupport = false;
        cryptsetupSupport = false;
        nlsSupport = false;
        ncursesSupport = false;
      };
      coreutils-full = self.coreutils;
      dbus = super.dbus.override {
        x11Support = false;
      };
      wireplumber = super.wireplumber.override {
        enableGI = false;
      };
      systemd = super.systemd.override {
        withAcl = false;
        withAnalyze = true;
        withApparmor = false;
        withAudit = false;
        withCoredump = false;
        withDocumentation = false;
        withFido2 = false;
        withGcrypt = false;
        withHostnamed = false;
        withHomed = false;
        withHwdb = false;
        withImportd = false;
        withLibBPF = false;
        withLibidn2 = false;
        withLocaled = false;
        withMachined = false;
        withNetworkd = false;
        withNss = false;
        withOomd = false;
        withPCRE2 = false;
        withPolkit = false;
        withPortabled = false;
        withRemote = false;
        withResolved = false;
        withShellCompletions = false;
        withSysusers = false;
        withTimedated = false;
        withTimesyncd = false;
        withTpm2Tss = false;
        withUserDb = false;
        withPasswordQuality = false;
        withVmspawn = false;
        withLibarchive = false;
        #nice
        withKmod = false;
        # Needed
        withPam = true;
        withCompression = true;
        withLogind = true;
        withQrencode = false;
        withUkify = false;
        withEfi = true;
        withCryptsetup = true;
        withRepart = true;
        withSysupdate = false;
        withOpenSSL = false;
        withBootloader = false;
      };
    })
  ];
  systemd.coredump.enable = false;
  systemd.repart.enable = false;
  system.switch.enable = false;
  nix.enable = false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
}
