# ver 01.02 - Optimized for Intel + NVIDIA 740M (Kepler) + RU Keyboard Layout
{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- BOOTLOADER AND KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Using Xanmod kernel for better desktop responsiveness
  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  # Remove nouveau to prevent conflicts with proprietary NVIDIA drivers
  boot.blacklistedKernelModules = [ "nouveau" ];

  # --- NETWORKING ---
  networking.networkmanager.enable = true;
  networking.firewall.enable = false; # Disabled as per your original config

  # --- GRAPHICS AND VULKAN (HYBRID INTEL + NVIDIA 740M) ---
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam and older games
    extraPackages = with pkgs; [
      intel-media-driver # Hardware acceleration for Intel CPU
      intel-vaapi-driver
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false; # Kepler (700 series) has issues with new power management
    open = false; # Open-source kernel modules are not supported on 700 series
    
    # GT 740M (Kepler) requires the Legacy 470 driver branch
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # Usage: 'nvidia-offload <program>'
      };
      # PCI IDs from your lspci output: Intel (00:02.0), NVIDIA (01:00.0)
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };


    # Environment variables for Vulkan
  environment.variables = {
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json:/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
  };

  # --- DESKTOP ENVIRONMENT (LXQT) ---
  services.xserver = {
    enable = true;
    desktopManager.lxqt.enable = true;
    displayManager.lightdm.enable = true;    
    
    # Keyboard settings: English and Russian layouts
    # Switching shortcut: Caps Lock
    xkb = {
      layout = "us,ru";
      variant = ",winkeys";
      options = "grp:caps_toggle";
    };
  };

  services.displayManager.defaultSession = "lxqt";

  # --- USER ACCOUNTS ---
  users.users.admin = {
    isNormalUser = true;
    description = "System Admin";
    # Fixed typo: 'networkingmanager' -> 'networkmanager'
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ]; 
    initialPassword = "root"; 
  };

  # --- SYSTEM PACKAGES & OPTIMIZATIONS ---
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };

  programs.steam.enable = true;
  programs.firefox.enable = true;
  programs.gamemode.enable = true; # Optimizes CPU/GPU priorities for gaming
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    wget
    firefox
    htop
    nvtopPackages.nvidia # Terminal GPU monitor
    vulkan-tools
    mesa-demos
    pciutils
  ];

  # CPU and Power management (Performance focus)
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    };
  };
  services.auto-cpufreq.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  nix.settings = {
    max-jobs = "auto";
    cores = 0; # Utilize all CPU cores
  };

  swapDevices = [ { device = "/swapfile"; size = 4096; } ];

  # --- SYSTEM SERVICES ---
  services.openssh.enable = true;
  system.stateVersion = "24.11"; 
}
