{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  callPackage,
  yad,
  ...
}: let
  rev = "eaa660d39bf3f49b136c98c87c35e3e12f118f8f";
  hash = "sha256-7lkx/O4dOdVqAPX6s2IkkM6Ggbzmz9sm++20BBeoUQ4=";
in
  stdenv.mkDerivation rec {
    pname = "winapps";
    version = "git+${rev}";

    src = fetchFromGitHub {
      owner = "winapps-org";
      repo = "WinApps-Launcher";

      inherit rev hash;
    };

    nativeBuildInputs = [makeWrapper];
    buildInputs = [yad (callPackage ../winapps {})];

    postPatch = ''
      sed -E -i \
        -e "$(printf "%s$src%s" 's|^declare -rx ICONS_PATH="./Icons"|declare -rx ICONS_PATH="' '/Icons"|')" \
        WinAppsLauncher.sh
    '';

    installPhase = ''
      runHook preInstall

      patchShebangs WinAppsLauncher.sh
      install -m755 -D WinAppsLauncher.sh $out/bin/winapps-launcher

      wrapProgram $out/bin/winapps-launcher --prefix PATH : "${lib.makeBinPath buildInputs}"

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/winapps-org/WinApps-Launcher";
      description = "Graphical launcher for WinApps. Run Windows applications (including Microsoft 365 and Adobe Creative Cloud) on GNU/Linux with KDE, GNOME or XFCE, integrated seamlessly as if they were native to the OS. Wayland is currently unsupported.";
      mainProgram = "winapps-launcher";
      platforms = platforms.linux;
      license = licenses.gpl3;
    };
  }
