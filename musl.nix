{ pkgs, lib, config, ... }:
let
  glibcPkgs = (import pkgs.path { system = pkgs.hostPlatform.system; });
  efiArch = pkgs.stdenv.hostPlatform.efiArch;
in
{
  imports = [
    ./kmod-issue.nix # Failed to initialize kmod context: Not supported
    ./super-minimal.nix
  ];
  services.nscd.enableNsncd = false;
  services.nscd.enable = false;
  system.nssModules = lib.mkForce [];
  boot.bcache.enable = false;
  i18n.glibcLocales = pkgs.runCommandNoCC "neutered" { } "mkdir -p $out";
  image.repart.partitions."20-esp".contents."/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = lib.mkForce  "${glibcPkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
  boot.uki.settings.UKI.Stub =
    "${glibcPkgs.systemd}/lib/systemd/boot/efi/linux${pkgs.stdenv.hostPlatform.efiArch}.efi.stub";
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
  ];
  nixpkgs.overlays = [
    (self: super: {
      qemu = glibcPkgs.qemu;
      systemdUkify = self.systemd.override {
        withUkify = true;
        withBootloader = true;
        withEfi = true;
      };
      systemd = (super.systemd.override {
        kbd = self.kbd.overrideAttrs { unpackPhase = "mkdir -p {$out/bin,$dev,$man,$scripts}; touch $out/bin/{loadkeys,setfont}; exit 0"; };
        coreutils = self.runCommandNoCC "neutered" { } "mkdir -p $out";
        withUkify = false;
        withRepart = false;
        withCryptsetup = false;
        withEfi = false;
        withBootloader = false;

        withAcl = false;
        withAnalyze = false;
        withApparmor = false;
        withAudit = false;
        withCompression = false;
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
        withLogind = false;
        withMachined = false;
        withNetworkd = false;
        withNss = false;
        withOomd = false;
        withOpenSSL = false;
        withPCRE2 = false;
        withPam = false;
        withPolkit = false;
        withPortabled = false;
        withRemote = false;
        withResolved = false;
        withShellCompletions = false;
        withSysupdate = false;
        withSysusers = false;
        withTimedated = false;
        withTimesyncd = false;
        withTpm2Tss = false;
        withUserDb = false;
        withPasswordQuality = false;
        withVmspawn = false;
        withQrencode = false;
        withLibarchive = false;
      });
      move-mount-beneath = super.move-mount-beneath.overrideAttrs (old: {
        patches = old.patches ++ [
          ./move-mount-beneath-musl.patch
        ];
      });
    })
  ];
  environment.corePackages = with pkgs; [
    acl
    attr
    bashInteractive
    bzip2
    coreutils-full
    cpio
#    curl
#    diffutils
    findutils
    gawk
    getent
    getconf
    gnugrep
    gnupatch
    gnused
    gnutar
    gzip
    xz
    less
    libcap
    ncurses
    netcat
    mkpasswd
    procps
    su
    time
    util-linux
    which
    zstd
  ];
}
