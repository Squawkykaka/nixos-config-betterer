{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  libGL,
  xorg,
  ...
}:
buildDotnetModule rec {
  pname = "sclauncher";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "Alienmario";
    repo = "SCLauncher";
    rev = "v${version}";
    hash = "sha256-6YzUCFrXjV8hJU56WvFthcsu/mMlf18rLWFOng5eeYQ=";
  };

  projectFile = "SCLauncher/SCLauncher.csproj";
  nugetDeps = ./deps.json;

  executables = [ "SCLauncher" ];

  dotnet-sdk = dotnetCorePackages.dotnet_9.sdk;

  runtimeDependencies = [
    libGL
    xorg.libX11
    xorg.libXfixes
    xorg.libXext
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];
}
