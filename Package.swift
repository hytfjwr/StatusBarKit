// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "StatusBarKit",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "StatusBarKit", type: .dynamic, targets: ["StatusBarKit"]),
        .library(name: "StatusBarIPC", targets: ["StatusBarIPC"]),
    ],
    targets: [
        .target(
            name: "StatusBarIPC",
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
            ]
        ),
        .target(
            name: "StatusBarKit",
            dependencies: ["StatusBarIPC"],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .unsafeFlags(["-Xlinker", "-install_name", "-Xlinker", "@rpath/libStatusBarKit.dylib"]),
            ]
        ),
        .testTarget(
            name: "StatusBarKitTests",
            dependencies: ["StatusBarKit"]
        ),
    ]
)
