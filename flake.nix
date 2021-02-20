{
  description = "Free (as in freedom) open source clone of the Age of Empires II engine";

  inputs = {
    openage = { url = github:SFTtech/openage; flake = false; };
    flake-utils.url = github:numtide/flake-utils;
    nyan = { url = github:vi-tality/nyan-flake; flake = true; };
  };

  outputs = { self, nixpkgs, flake-utils, nyan, ... }@inputs: flake-utils.lib.eachDefaultSystem (system:
    with nixpkgs.legacyPackages."${system}";
    let
      openage = nixpkgs.legacyPackages."${system}".stdenv.mkDerivation {
        postFixup = ''
          mv $out/bin/openage $out/lib/python3.8/site-packages/run.py
          ln -s $out/lib/python3.8/site-packages/run.py $out/bin/run.py
        '';

        pname = "openage";
        version = "master";
        src = inputs.openage;

        cmakeFlags = ["-Dnyan_DIR=${inputs.nyan.outputs.defaultPackage.x86_64-linux}/lib/cmake/nyan/"];

        buildInputs = [
          inputs.nyan
          cmake
          eigen
          epoxy
          fontconfig
          freetype
          harfbuzz
          libogg
          libpng
          lz4
          SDL2
          SDL2_image
          opusfile
          (qtEnv "openage-qt-env" (with qt5; [
            qtquick1
            #qmake
            qtcharts
            qtconnectivity
            qtdeclarative
            qtdoc
            #qtgamepad
            qtgraphicaleffects
            qtimageformats
            qtlocation
            qtmultimedia
            qtnetworkauth
            qtquickcontrols
            qtquickcontrols2
            qtscript
            qtscxml
            qtsensors
            qtserialport
            qtspeech
            qtsvg
            qttools
            qttranslations
            qtvirtualkeyboard
            #qtwayland
            qtwebchannel
            qtwebengine
            qtwebglplugin
            qtwebkit
            qtwebsockets
            qtwebview
            qtx11extras
            qtxmlpatterns
          ]))
        ];
        propagatedBuildInputs = [
          (python3.buildEnv.override {
            extraLibs = with pkgs.python3Packages; [
              cython
              numpy
              jinja2
              lz4
              pillow
              pygments
              toml
            ];
          })
          dejavu_fonts
        ];

      };
    in
    rec {
      defaultPackage = openage;

      apps = {
        openage = flake-utils.lib.mkApp {
          drv = defaultPackage;
          name = "openage";
        };
      };

    });
}
