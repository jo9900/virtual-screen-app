// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VirtualScreen",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "virtual-screen", targets: ["VirtualScreen"]),
    ],
    targets: [
        .target(
            name: "CGVirtualDisplayPrivate",
            linkerSettings: [.linkedFramework("CoreGraphics")]
        ),
        .target(name: "VirtualScreenCore"),
        .executableTarget(
            name: "VirtualScreen",
            dependencies: ["CGVirtualDisplayPrivate", "VirtualScreenCore"]
        ),
        .testTarget(
            name: "VirtualScreenCoreTests",
            dependencies: ["VirtualScreenCore"]
        ),
    ]
)
