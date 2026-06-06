// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Uninstaller",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "Uninstaller",
            path: "Sources/Uninstaller"
        )
    ]
)
