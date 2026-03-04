{
  lib,
  olm,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "matterbridge";
  version = "1.26.0-unstable-2024-08-27";

  src = fetchFromGitHub {
    owner = "matterbridge-org";
    repo = "matterbridge";
    rev = "6d468adbf1f199e581c3ed63e4933abdfb0419a6";
    hash = "sha256-ZTtvvrQk8EW+C7hn2tXAZNPD0c5PmklV4W2bnQx1MnQ=";
  };

  subPackages = [ "." ];

  vendorHash = "sha256-PHPFdKczw2f80sGMHUAz9ZE5zboV8jxzGia7K5uTdb4=";

  buildInputs = [ olm ];

  meta = {
    description = "Community Fork, Simple bridge between Mattermost, IRC, XMPP, Gitter, Slack, Discord, Telegram, Rocket.Chat, Hipchat(via xmpp), Matrix and Steam";
    homepage = "https://github.com/42wim/matterbridge";
    license = with lib.licenses; [ agpl3Only ];
    mainProgram = "matterbridge";
  };
}
