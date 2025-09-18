{ buildUBoot, armTrustedFirmwareRK3588, rkbin, fetchFromGitHub }:
buildUBoot {
  defconfig = "rock-5c-rk3588s_defconfig";
  src = fetchFromGitHub {
    owner = "u-boot";
    repo = "u-boot";
    rev = "f28891d444631c91a6e090927486a2169b51b20f";
    hash = "sha256-J/8xgQJJBgnpXfv0sTV78Lphq+lQ2b8BHP/Ei7hXcbE=";
  };
  patches = [];
  version = "master";
  extraConfig = ''
    CONFIG_BOOTDELAY=1
  '';
  extraMeta.platforms = [ "aarch64-linux" ];
  BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
  ROCKCHIP_TPL = rkbin.TPL_RK3588;
  filesToInstall = [
    "u-boot.itb"
    "idbloader.img"
    "u-boot-rockchip.bin"
  ];
}


