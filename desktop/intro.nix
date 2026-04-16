{
  # ULTRAKILL YEAHHHHH
  boot.initrd.stage1Greeting = "MANKIND IS DEAD";
  boot.stage2Greeting = "BLOOD IS FUEL";
  system.activationScripts = {
    ultrakill = {
      text = # sh
        ''
          echo
          echo -e "\e[1;32mHELL IS FULL\e[0m"
          echo
        '';
    };
  };
}
