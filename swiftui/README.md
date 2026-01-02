# SwiftUI

This is a minimal proof-of-concept attempting to make truly reproducible macOS apps using SwiftUI.

## Nix
We're using nix to provide a hermetic toolchain, and are avoiding Xcode at all costs. For the initial iteration, we are using `apple-sdk_14` rather than `apple-sdk_26`, as the latter requires Swift 6 which is not yet available via nix (see [this issue](https://github.com/NixOS/nixpkgs/issues/343210)).
