{
  pkgs,
  lib,
  ...
}: {
  services.pcscd.enable = true;
  programs.ssh.startAgent = lib.mkForce false;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    enableSSHSupport = true;
  };
}
