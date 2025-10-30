// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacroRecorder",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MacroRecorder",
            targets: ["MacroRecorder"]
        )
    ],
    targets: [
        .executableTarget(
            name: "MacroRecorder",
            path: "MacroRecorder",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
