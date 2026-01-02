{
  description = "Minimal reproducible SwiftUI macOS app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      # Support all Darwin platforms
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # Helper to generate attrs for each system
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      appName = "MinimalSwiftUI";

      # Reusable derivation builder - takes target pkgs (native or cross)
      mkApp =
        pkgs:
        let
          inherit (pkgs) swiftPackages;
          inherit (pkgs.lib) fileset;
          sourceFiles = fileset.fileFilter (file: file.hasExt "swift") ./src;
        in
        swiftPackages.stdenv.mkDerivation {
          pname = "minimal-swiftui";
          version = "0.1.0";

          src = fileset.toSource {
            root = ./src;
            fileset = sourceFiles;
          };

          nativeBuildInputs = [
            swiftPackages.swift
          ];

          buildInputs = [
            pkgs.apple-sdk_14
          ];

          buildPhase = ''
            swiftc \
              -o ${appName} \
              -framework SwiftUI \
              -framework AppKit \
              -framework Foundation \
              -Xfrontend -no-serialize-debugging-options \
              -Xlinker -reproducible \
              $(ls *.swift | sort)
          '';

          installPhase = ''
            mkdir -p $out/Applications/${appName}.app/Contents/MacOS
            mkdir -p $out/Applications/${appName}.app/Contents/Resources

            mv ${appName} $out/Applications/${appName}.app/Contents/MacOS/

            cat > $out/Applications/${appName}.app/Contents/Info.plist << EOF
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>CFBundleName</key>
                <string>${appName}</string>
                <key>CFBundleDisplayName</key>
                <string>${appName}</string>
                <key>CFBundleIdentifier</key>
                <string>com.example.minimal-swiftui</string>
                <key>CFBundleVersion</key>
                <string>1.0</string>
                <key>CFBundleShortVersionString</key>
                <string>1.0</string>
                <key>CFBundlePackageType</key>
                <string>APPL</string>
                <key>CFBundleExecutable</key>
                <string>${appName}</string>
                <key>LSMinimumSystemVersion</key>
                <string>11.0</string>
                <key>NSHighResolutionCapable</key>
                <true/>
                <key>NSPrincipalClass</key>
                <string>NSApplication</string>
            </dict>
            </plist>
            EOF

            mkdir -p $out/bin
            ln -s $out/Applications/${appName}.app/Contents/MacOS/${appName} $out/bin/${appName}
          '';

          meta = {
            description = "Minimal SwiftUI macOS application";
            platforms = supportedSystems;
          };
        };

    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Explicit targets - one native, one cross-compiled depending on host
          pkgsAarch64 =
            if system == "aarch64-darwin" then pkgs else pkgs.pkgsCross.aarch64-darwin;
          pkgsX86_64 =
            if system == "x86_64-darwin" then pkgs else pkgs.pkgsCross.x86_64-darwin;
        in
        {
          default = mkApp pkgs;
          aarch64 = mkApp pkgsAarch64;
          x86_64 = mkApp pkgsX86_64;
        }
      );

      # Development shell with Swift tooling
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.swiftPackages.swift
              pkgs.apple-sdk_14
            ];
          };
        }
      );
    };
}
