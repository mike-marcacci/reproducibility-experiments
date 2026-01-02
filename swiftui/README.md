# SwiftUI

This is a minimal proof-of-concept attempting to make truly reproducible macOS apps using SwiftUI.

## Nix
We're using nix to provide a hermetic toolchain, and are avoiding Xcode at all costs. For the initial iteration, we are using `apple-sdk_14` rather than `apple-sdk_26`, as the latter requires Swift 6 which is not yet available via nix (see [this issue](https://github.com/NixOS/nixpkgs/issues/343210)).

## Signing and Verification

The build produces an unsigned `.app` bundle with bit-for-bit reproducibility. For distribution, signing and notarization are handled separately:

1. **Build** with Nix (reproducible, unsigned)
2. **Sign** with the Xcode toolchain (`codesign`)
3. **Notarize** via Apple (required for distribution since macOS Catalina)

### Verifying a signed distribution

Code signing modifies the Mach-O binary structure (adds load commands, padding, signature data). Running `codesign --remove-signature` removes the signature but doesn't perfectly restore the original structure. To verify a distributed binary:

```bash
# Build from source
nix build .#default
cp -r result/Applications/MinimalSwiftUI.app ./local-build.app

# Strip signatures from both (normalizes structure)
codesign --remove-signature ./local-build.app
codesign --remove-signature ./distributed.app

# Remove notarization artifacts
xattr -cr ./distributed.app

# Compare
diff -r ./local-build.app ./distributed.app
```

Stripping both binaries—even the nominally unsigned local build—ensures structural normalization for comparison.

### Notes

- **Entitlements** and **Hardened Runtime** are applied at signing time, not build time, so they don't affect reproducibility
- The `Info.plist` contains only static values; adding timestamps or build numbers would break reproducibility
