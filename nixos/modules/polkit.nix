{ pkgs, ...}: {
  security.polkit.enable = true;
  
  environment.systemPackages = with pkgs; [
    kdePackages.polkit-kde-agent-1
  ];
}