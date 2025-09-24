{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      flake = rec {
        herculesCI.ciSystems = [ "aarch64-linux" ];
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
          flash-rk3588 =
            let
              spl = pkgs.fetchurl {
                url = "https://dl.radxa.com/rock5/sw/images/loader/rock-5b/release/rk3588_spl_loader_v1.15.113.bin";
                hash = "sha256-JrqrcOa5FTZPfXPYgpg2bbG/w0bjRoPpXT0RtSSSBH8=";
              };
              decompressedImage = pkgs.runCommand "rk3588-image-decompressed" {} ''
                ${pkgs.zstd}/bin/zstdcat ${inputs.self.packages.aarch64-linux.rk3588s-musl-image}/*.zst > $out
              '';
              program = pkgs.writeShellScriptBin "flash-cm5" ''
                PATH=${pkgs.lib.makeBinPath (with pkgs; [ rkdeveloptool mktemp coreutils ])}
                TMPDIR=$(mktemp -d)
                echo "Please use your fingers to put the board into maskrom mode"
                echo "Flashing the image from ${decompressedImage}"
                until rkdeveloptool db ${spl}
                do
                  echo "Waiting for device to accept SPL loader... retrying in 1 second"
                  sleep 1
                done
                rkdeveloptool wl 0 ${decompressedImage}
                rkdeveloptool rd
              '';
            in program;
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
