// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CycleEngine",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CycleEngine",
            targets: ["CycleEngine"]
        ),
    ],
    targets: [
        .target(
            name: "CycleEngine"
        ),
        .testTarget(
            name: "CycleEngineTests",
            dependencies: ["CycleEngine"],
            resources: [
                .copy("TestData")
            ]
        ),
    ]
)
