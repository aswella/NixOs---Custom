#ver 00.01

{ config, lib, pkgs, ... }:

{
    imports =
      [
        ./hardware-configuration.nix
      ];
  
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_xanmod; # Or linuxPackages_zen
  
    networking.networkmanager.enable = true;
  
    programs.steam.enable = true;
    programs.firefox.enable = true;
  
     environment.systemPackages = with pkgs; [
       wget
       firefox
       htop
     ];
  
     programs.mtr.enable = true;
     programs.gnupg.agent = {
       enable = true;
       enableSSHSupport = true;
     };
  
  
     services.openssh.enable = true;
     networking.firewall.allowedTCPPorts = [ 22 ];
     networking.firewall.allowedUDPPorts = [ 22 ];
     networking.firewall.enable = false;
  
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      };
    };
  
    nix.settings = {
      max-jobs = "auto";
      cores = 0;
    };
    
    services.auto-cpufreq.enable = true; 
    nixpkgs.config.allowUnfree = true;
    boot.blacklistedKernelModules = ["nouveau" "mvidia"];
    powerManagement.cpuFreqGovernor = "performance";
    swapDevices = [ { device = "/swapfile"; size = 4096; } ];
    services.xserver.enable = true;
    services.xserver.desktopManager.lxqt.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.displayManager.defaultSession = "lxqt";
    services.xserver.videoDrivers = ["modesetting"];
    hardware.opengl.enable = true;
  
    users.users.admin = {
            isNormalUser = true;
            description = "root";
            extraGroups = ["networkingmanager" "wheel" "video" "audio"];
            initialPassword = "root"; #WHO USES THIS CHANGE TO NEW PASS
    };
  
    system.stateVersion = "25.11";
}

