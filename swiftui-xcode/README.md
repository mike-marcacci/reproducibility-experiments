# SwiftUI Xcode

A reproducible SwiftUI macOS app with full Xcode development support including SwiftUI previews.

## Project Structure

```
swiftui-xcode/
├── src/                          # Shared source files (compiled by both)
│   ├── App.swift                 # Application entry point
│   └── ContentView.swift         # Main view
├── Previews/                     # Xcode-only (not compiled by Nix)
│   └── ContentView+Preview.swift # SwiftUI previews using #Preview macro
├── MinimalSwiftUI.xcodeproj/     # Xcode project (for development)
├── flake.nix                     # Nix build (for CI/production)
└── README.md
```

The `Previews/` folder contains `#Preview` macros which require Xcode's macro expansion system. These files are only compiled by Xcode, not by the Nix build.

## Development Workflow (Xcode)

For rapid iteration with SwiftUI previews:

1. Open `MinimalSwiftUI.xcodeproj` in Xcode
2. SwiftUI previews work with the `#Preview` macro
3. Use Cmd+R to build and run
4. Full debugging support

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

## Architecture

This approach separates concerns:

- **Xcode project**: Full IDE experience with previews, debugging, profiling
- **Nix flake**: Reproducible builds using direct `swiftc` compilation

Both use the same source files in `src/`, so changes are immediately reflected in both workflows.

## Reproducibility

The Nix build uses direct `swiftc` invocation with explicit flags:

- `-Xfrontend -no-serialize-debugging-options`: Removes debug path information
- `-Xlinker -reproducible`: Ensures deterministic linking

The Xcode build does NOT produce reproducible binaries (due to timestamps, debug info, etc.), but that's fine—it's only for development.

## Swift Macro Limitations

Nix's Swift (currently 5.10.1) includes `swiftc` but not the macro plugin infrastructure required for Swift 5.9+ macros. This affects:

| Macro | Framework | Workaround |
|-------|-----------|------------|
| `#Preview` | SwiftUI | Use `Previews/` folder (Xcode-only) |
| `@Observable` | Observation | Use `ObservableObject` + `@Published` |
| `@Model` | SwiftData | Use Core Data or avoid |
| `#expect`, `#require` | Swift Testing | Use XCTest |

**Recommendation**: Use the pre-Swift 5.9 patterns (`ObservableObject`, XCTest, etc.) in `src/` for compatibility with both Xcode and Nix builds.

This limitation should be resolved when Swift 6 becomes available in nixpkgs. Track progress at [nixpkgs#343210](https://github.com/NixOS/nixpkgs/issues/343210).

## Signing and Verification

The Nix build produces an unsigned `.app` bundle. For distribution:

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

## Comparison with Other Approaches

| Approach | Xcode Previews | Nix Build | Complexity |
|----------|---------------|-----------|------------|
| `swiftui-minimal` | No | Direct swiftc | Low |
| `swiftui-package` | Limited | SPM | Medium |
| `swiftui-xcode` | Full | Direct swiftc | Medium |

This approach (`swiftui-xcode`) provides the best developer experience while maintaining reproducible production builds.
