{
  stdenvNoCC,
  fetchurl,
  dpkg,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "racadm";
  version = "10.3.0.0";

  src = fetchurl {
    url = "https://dl.dell.com/FOLDER08637461M/1/DellEMC-iDRACTools-Web-LX-10.3.0.0-4945_A00.tar.gz";
    hash = "";
  };

  nativeBuildInputs = [ dpkg ];

  installPhase = ''
    mkdir $out
    cp -r . $out
  '';
}
