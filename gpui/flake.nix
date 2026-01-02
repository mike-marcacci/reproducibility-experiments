{
  description = "Minimal reproducible GPUI macOS app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      crane,
    }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-darwin" ] (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        craneLib = crane.mkLib pkgs;

        src = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: type: (craneLib.filterCargoSources path type);
        };

        commonArgs = {
          inherit src;
          strictDeps = true;
        };

        cargoArtifacts = craneLib.buildDepsOnly commonArgs;

      in
      {
        packages = {
          default = craneLib.buildPackage (
            commonArgs
            // {
              inherit cargoArtifacts;

              postInstall = ''
                            mkdir -p $out/Applications/NixGPUIExample.app/Contents/MacOS
                            cp $out/bin/nix-gpui-example $out/Applications/NixGPUIExample.app/Contents/MacOS/
                            cat > $out/Applications/NixGPUIExample.app/Contents/Info.plist << 'EOF'
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                    <key>CFBundleExecutable</key>
                    <string>nix-gpui-example</string>
                    <key>CFBundleIdentifier</key>
                    <string>com.example.nix-gpui-example</string>
                    <key>CFBundleName</key>
                    <string>Nix GPUI Example</string>
                    <key>CFBundleVersion</key>
                    <string>0.1.0</string>
                    <key>CFBundleShortVersionString</key>
                    <string>0.1.0</string>
                    <key>CFBundlePackageType</key>
                    <string>APPL</string>
                    <key>NSHighResolutionCapable</key>
                    <true/>
                </dict>
                </plist>
                EOF
              '';
            }
          );
        };

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
        };

        devShells.default = craneLib.devShell {
          packages = with pkgs; [
            rust-analyzer
            cargo-watch
          ];
        };

        checks = {
          fmt = craneLib.cargoFmt { inherit src; };
          build = self.packages.${system}.default;
        };
      }
    );
}
