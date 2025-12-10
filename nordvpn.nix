{
  buildFHSEnvChroot,
  fetchurl,
  lib,
  stdenv,
  libxml2_13,
  libidn2,
  libnl,
  libcap_ng,
  sqlite,
  dpkg,
  autoPatchelfHook,
  sysctl,
  iptables,
  iproute2,
  procps,
  cacert,
}:

let
  pname = "nordvpn";
  version = "4.2.1";

  nordVPNBase = stdenv.mkDerivation {
    pname = "nordvpn-core";
    inherit version;
    
    src =
    if stdenv.hostPlatform.system == "x86_64-linux"
    then fetchurl {
      url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${version}_amd64.deb";
      hash = "sha256-DMyNPc08txvkAB3QKK4ViHomsr3Z3l6JerUQ0zuRlro=";
    }
    else if stdenv.hostPlatform.system == "aarch64-linux"
    then fetchurl {
      url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${version}_arm64.deb";
      hash = "sha256-/doGY/xm4Da0TffgbSjCRp96yrv7Xz72b7eM9u8CPas=";
    }
    else throw "Unsupported platform: ${stdenv.hostPlatform.system}";
      
    buildInputs = [
      libxml2_13
      libidn2
      libnl
      libcap_ng
      sqlite
    ];

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      stdenv.cc.cc.lib
    ];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg --extract $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      mv usr/* $out/
      mv var/ $out/
      mv etc/ $out/
      runHook postInstall
    '';
  };

  nordVPNfhs = buildFHSEnvChroot {
    name = "nordvpnd";
    runScript = "${nordVPNBase}/bin/nordvpnd";

    targetPkgs = pkgs: with pkgs; [
      nordVPNBase
      sysctl
      iptables
      iproute2
      procps
      cacert
      wireguard-tools
    ];
  };
in
stdenv.mkDerivation {
  inherit pname version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share
    ln -s ${nordVPNBase}/bin/nordvpn $out/bin
    ln -s ${nordVPNfhs}/bin/nordvpnd $out/bin
    ln -s ${nordVPNBase}/share/* $out/share/
    ln -s ${nordVPNBase}/var $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "CLI client for NordVPN";
    homepage = "https://www.nordvpn.com";
    license = licenses.unfreeRedistributable;
    maintainers  = with maintainers; [ scouckel ];
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
