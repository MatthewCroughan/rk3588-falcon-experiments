{ pkgs, config, ... }:
{
  hardware.deviceTree = {
    name = "rockchip/rk3588s-radxa-cm5-io.dtb";
    kernelPackage = config.boot.kernelPackages.kernel.overrideAttrs {
      outputs = [ "out" ];
      configurePhase = ''
        DTS=arch/arm64/boot/dts/rockchip/rk3588s-radxa-cm5-io.dts
        cp ${./rk3588s-radxa-cm5.dtsi} "arch/arm64/boot/dts/rockchip/rk3588s-radxa-cm5.dtsi"
        cp ${./rk3588s-radxa-cm5-io.dts} "arch/arm64/boot/dts/rockchip/rk3588s-radxa-cm5-io.dts"
        mkdir -p "$out/dtbs/rockchip"
        $CC -E -nostdinc -Iinclude -undef -D__DTS__ -x assembler-with-cpp "$DTS" | \
          ${pkgs.dtc}/bin/dtc -I dts -O dtb -@ -o $out/dtbs/rockchip/rk3588s-radxa-cm5-io.dtb
        exit 0
        '';
      };
  };
}
