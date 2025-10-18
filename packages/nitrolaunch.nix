# { symlinkJoin, buildFHSEnv,  }:let
#   fhsEnv = {
#     inherit
#   };
# in
# symlinkJoin {
#   name = "nitrolaunch";
#   paths = [
#     (buildFHSEnv (
#       fhsEnv
#       // {
#         pname = "nitrolaunch-gui";
#         runScript = "nitrolaunch";
#       }
#     ))
#     (buildFHSEnv (
#       fhsEnv
#       // {
#         pname = "nitrolaunch-cli";
#         runScript = "nitro";
#       }
#     ))
#   ];
# }
{}: {}
