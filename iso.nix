{
  lib,
  pkgs,
  ...
}: let
  sshkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD7BCsBNKIWU9gDfFmOX4/tQTFfKumFrDJ0CQS0CO0tn8ORI28jdJu8SL67oe65DRI8oBpIUeoqh3g9xTMurFbG108CCR8w8s5lKSgNEfbfy9NWKVSfUeg2m6qv9jQQBtvPkmC+NyijtziSmglEWQCJd9rwE9qElghJM3Ju4WRJSWTVZobzFxkSYy8e72rpMIpspIX4sLT+QPMRGL1Lub2HKBEmE2E1aWbqUGPUOBwJiwI/NkU2BhHwPeg+nmGMgrs/EqFQ5oADnatp4B+iMA1CQ0YlAdyIjM8ivaOfxNUfH9D/GeDG6HTEfsuU33HMD7kP1GEZfb6ghQi7iMtd5ymfI7aRguNqqnalCCANZhVJUXXTPj/le5nwos69PHB1SkoCeDvWckXAmldY3d/3mRlWo0RrbHnvfQApWBL1j/4wotR4niJdYMCDSehpM8jbK8yArT5fToCWJlSrxlX5/z+JI42QpvfezvGAwo6jmo0q4qBTrFcAEdsjWu/HjYb/d8S+MUM01SmAxve3jmAVfPDexG/+TK+lD5aXgHxCRkwqBJHJwCQzLLlvOnAS9xXdKN7cP/2cQQb+JDg15gvA9w+XDSnmnFvWg62kEJ+RIFFqSrOFeuzXk99TWU8j3ikqPngF4pNrLe3ta7DT0yaFo1nte5cqywOWVuUZdXYoBLPohw== openpgp:0x7000CCFE";
in {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  networking.wireless.enable = false;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  users = {
    mutableUsers = true;
    users = {
      root = {
        initialPassword = "nixroot";
        openssh.authorizedKeys.keys = [sshkey];
      };

      nixos = {
        initialPassword = "nixroot";
        openssh.authorizedKeys.keys = [sshkey];

        extraGroups = [
          "wheel"
          "video"
          "audio"
          "networkmanager"
          "libvirtd"
          "kvm"
          "docker"
          "git"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    just
    git
    rsync
  ];
}
