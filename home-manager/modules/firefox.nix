# { inputs, ... }:
{
  # imports = [ inputs.arkenfox.hmModules.arkenfox ];

  programs.firefox = {
    enable = false;
    # arkenfox = {
    #   enable = false;
    #   version = "135.0";
    # };

    # profiles.Default.arkenfox = {
    #   enable = true;
    #   "0000".enable = true;

    #   "0100" = {
    #     enable = true;
    #     "0102"."browser.startup.page".value = 3;
    #   };
    #   "0200".enable = true;
    #   "0300".enable = true;
    #   "0300"."0320"."extensions.getAddons.showPane".value = true;
    #   "0400".enable = true;
    #   "0900".enable = true;
    # };
  };
}
