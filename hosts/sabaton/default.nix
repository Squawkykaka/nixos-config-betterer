##############################################################
#
#  Sabaton - Thinkpad X1 Extreme Gen 2
#  NixOS running on Intel Core i7, Nvidia GTX 1650 Mobile, 16GB RAM
#
###############################################################
{
  self,
  pkgs,
  ...
}:
{
  imports = [
    "${self.sources.disko}/module.nix"
    ../../disks/btrfs-disk-luks.nix
  ];

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    IdleAction = "lock";
    IdleActionSec = 300;
  };
  systemd.sleep.settings.Sleep = {
    SuspendMode = "suspend";
    HibernateMode = "shutdown";
    HibernateDelaySec = 7200;
  };

  boot.zswap = {
    enable = true;
    compressor = "lz4";
  };

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # Enable TPM emulation (optional)
  # install pkgs.swtpm system-wide for use in virt-manager (optional)
  # Enable USB redirection (optional)
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  users.groups.media = {
    gid = 984;
  };
  users.users.gleask.extraGroups = [
    "kvm"
    "media"
    "libvirtd"
    "wireshark"
  ];

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "gleask";
  };

  # make sure my touchpad works when typing
  services.libinput.enable = true;
  services.libinput = {
    touchpad.disableWhileTyping = true;
  };

  networking.networkmanager.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
  '';

  # set the boot loader
  boot = {
    kernelParams = [
      "mem_sleep_default=deep"
      "nmi_watchdog=0"
      "snd_hda_intel.power_save=1"
    ];
    kernel.sysctl = {
      "vm.dirty_writeback_centisecs" = 1500;
    };

    loader = {
      systemd-boot.enable = false;
      limine.enable = true;
      limine.secureBoot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };

  environment.systemPackages = [ pkgs.sbctl ];

  # enable graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "24.11";
}
