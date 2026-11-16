// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VirtualScreenCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "VirtualScreenCore", targets: ["VirtualScreenCore"]),
    ],
    targets: [
        .target(
            name: "CGVirtualDisplayPrivate",
            linkerSettings: [.linkedFramework("CoreGraphics")]
        ),
        .target(
            name: "VirtualScreenCore",
            dependencies: ["CGVirtualDisplayPrivate"]
        ),
        .testTarget(
            name: "VirtualScreenCoreTests",
            dependencies: ["VirtualScreenCore"]
        ),
    ]
)
