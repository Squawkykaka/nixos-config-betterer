{
  lib,
  pkgs,
  config,
  ...
}: {
    # boot.blacklistedKernelModules = lib.mkDefault [ "i915" ];
    # # KMS will load the module, regardless of blacklisting
    # boot.kernelParams = lib.mkDefault [ "i915.modeset=0" ];
    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];
    services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
    hardware.nvidia = {
      # Modesetting is required.
      modesetting.enable = true;
      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = false;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;
      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;
      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.production;

      # enable prime offloading
      prime = {
        # sync.enable = true;
        offload = {
          enable = true;
          enableOffloadCmd = true; # Lets you use `nvidia-offload %command%` in steam
        };
        
        intelBusId = "PCI:00:02:0";
        nvidiaBusId = "PCI:01:00:0";
      };
    };
}
