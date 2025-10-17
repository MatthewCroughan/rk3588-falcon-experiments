{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.graphics.extraPackages = with pkgs; [
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
    vulkan-tools
  ];
  hardware.graphics.enable = true;
  environment.systemPackages = with pkgs; [ xscreensaver sway tio ];
}
