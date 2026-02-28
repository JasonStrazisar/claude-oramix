// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Claude-oramix",
    platforms: [.macOS(.v14)],
    targets: [
        .target(
            name: "Claude-oramix",
            path: "Claude-oramix",
            exclude: ["App/ClaudeOramixApp.swift"]
        ),
        .testTarget(
            name: "Claude-oramixTests",
            dependencies: ["Claude-oramix"],
            path: "Claude-oramixTests"
        )
    ]
)
