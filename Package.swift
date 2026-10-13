// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Tubecrate",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Tubecrate",
            path: "Sources/Tubecrate",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
