# SwiftUI Package

A reproducible SwiftUI macOS app that supports both Xcode development and Nix builds.

## Project Structure

```
swiftui-package/
├── Package.swift              # Swift Package Manager manifest
├── flake.nix                  # Nix build configuration
├── Sources/
│   └── MinimalSwiftUI/
│       ├── App.swift          # Application entry point
│       └── ContentView.swift  # Main view with SwiftUI preview
```

## Development Workflow (Xcode)

For rapid iteration with SwiftUI previews:

1. Open the project folder in Xcode (File → Open → select `swiftui-package/`)
2. Xcode automatically recognizes the `Package.swift`
3. SwiftUI previews work in `ContentView.swift`
4. Use Cmd+R to build and run

## CI/Production Workflow (Nix)

For reproducible builds:

```bash
# Build the app
nix build .#default

# Run the app
nix run

# Enter development shell
nix develop
```

## Reproducibility

This project uses Swift Package Manager as the common build system for both workflows. Reproducibility flags are specified in `Package.swift`:

- `-Xfrontend -no-serialize-debugging-options`: Removes debug path information
- `-Xlinker -reproducible`: Ensures deterministic linking

The Nix build uses `--disable-automatic-resolution` to prevent network access during builds. For projects with dependencies, commit `Package.resolved` to lock versions.

## Signing and Verification

The build produces an unsigned `.app` bundle. For distribution:

1. **Build** with Nix (reproducible, unsigned)
2. **Sign** with `codesign`
3. **Notarize** via Apple

### Verifying a signed distribution

```bash
# Build from source
nix build .#default
cp -r result/Applications/MinimalSwiftUI.app ./local-build.app

# Strip signatures from both
codesign --remove-signature ./local-build.app
codesign --remove-signature ./distributed.app

# Remove notarization artifacts
xattr -cr ./distributed.app

# Compare
diff -r ./local-build.app ./distributed.app
```

## Notes

- Uses `apple-sdk_14` (Swift 5.9) as Swift 6 is not yet available in nixpkgs
- The `Info.plist` contains only static values to preserve reproducibility
- Entitlements and Hardened Runtime are applied at signing time
