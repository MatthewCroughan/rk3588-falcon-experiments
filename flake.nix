{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-linux" ];
      flake = rec {
        nixosConfigurations.rk3588s = inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./configuration.nix
          ];
        };
        nixosConfigurations.rk3588s-musl = nixosConfigurations.rk3588s.extendModules {
          modules = [
            ./musl.nix
            {
              nixpkgs.crossSystem = {
                config = "aarch64-unknown-linux-musl";
              };
            }
          ];
        };
        nixosConfigurations.rk3588s-musl-llvm = nixosConfigurations.rk3588s.extendModules {
          modules = [
            ./musl-llvm.nix
            {
              nixpkgs.buildPlatform = (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-gnu");
              nixpkgs.hostPlatform = inputs.nixpkgs.lib.recursiveUpdate (inputs.nixpkgs.lib.systems.elaborate "aarch64-unknown-linux-musl") {
                useLLVM = true;
                linker = "lld";
                config = "aarch64-unknown-linux-musl";
              };
            }
          ];
        };
      };
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = {
          uboot = pkgs.callPackage ./uboot.nix {};
          rk3588s-image = inputs.self.nixosConfigurations.rk3588s.config.system.build.image.overrideAttrs {
            preInstall = ''
              dd if=${pkgs.callPackage ./uboot.nix {}}/u-boot-rockchip.bin of=${inputs.self.nixosConfigurations.rk3588s.config.image.baseName}.raw seek=64 conv=notrunc
            '';
          };
          rk3588s-musl-image = inputs.self.nixosConfigurations.rk3588s-musl.config.system.build.image.overrideAttrs {
            preInstall = ''
              dd if=${pkgs.callPackage ./uboot.nix {}}/u-boot-rockchip.bin of=${inputs.self.nixosConfigurations.rk3588s.config.image.baseName}.raw seek=64 conv=notrunc
            '';
          };
          rk3588s-musl-llvm-image = inputs.self.nixosConfigurations.rk3588s-musl-llvm.config.system.build.image.overrideAttrs {
            preInstall = ''
              dd if=${pkgs.callPackage ./uboot.nix {}}/u-boot-rockchip.bin of=${inputs.self.nixosConfigurations.rk3588s.config.image.baseName}.raw seek=64 conv=notrunc
            '';
          };
        };
      };
    };
}
