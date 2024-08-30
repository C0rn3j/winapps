{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  freerdp3,
  dialog,
  libnotify,
  netcat-gnu,
  iproute2,
  ...
}: let
  rev = "feat-install-script"; # "9417382ae73d2ae5ad69d1c5c407e8b1e5f001dc";
  hash = "sha256-iasuufBu+DhulH/hj2uUaM/KzGO7241+PZXuujsT/qI=";
in
  stdenv.mkDerivation rec {
    pname = "winapps";
    version = "git+${rev}";

    src = fetchFromGitHub {
      owner = "winapps-org";
      repo = "winapps";

      inherit rev hash;
    };

    nativeBuildInputs = [makeWrapper];
    buildInputs = [freerdp3 libnotify dialog netcat-gnu iproute2];

    postPatch = ''
      sed -E -i \
        -e "$(printf "%s$src%s" 's|^readonly SYS_SOURCE_PATH="(.*?)"|readonly SYS_SOURCE_PATH="' '"|')" \
        -e "$(printf "%s$src%s" 's|^readonly USER_SOURCE_PATH="(.*?)"|readonly USER_SOURCE_PATH="' '"|')" \
        -e 's/\$SUDO git -C "\$SOURCE_PATH" pull --no-rebase//g' \
        -e 's|./setup.sh|winapps-setup|g' \
        setup.sh
    '';

    installPhase = ''
      runHook preInstall

      patchShebangs install/inquirer.sh

      install -m755 -D bin/winapps $out/bin/winapps
      install -m755 -D setup.sh $out/bin/winapps-setup

      for f in winapps-setup winapps; do
        patchShebangs $f

        wrapProgram $out/bin/$f \
          --set LIBVIRT_DEFAULT_URI "qemu:///system" \
          --prefix PATH : "${lib.makeBinPath buildInputs}"
      done

      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/winapps-org/winapps";
      description = "Run Windows applications (including Microsoft 365 and Adobe Creative Cloud) on GNU/Linux with KDE, GNOME or XFCE, integrated seamlessly as if they were native to the OS. Wayland is currently unsupported.";
      mainProgram = "winapps";
      platforms = platforms.linux;
      license = licenses.gpl3;
    };
  }
