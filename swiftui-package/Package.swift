// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MinimalSwiftUI",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "MinimalSwiftUI",
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-no-serialize-debugging-options"])
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-reproducible"])
            ]
        )
    ]
)
