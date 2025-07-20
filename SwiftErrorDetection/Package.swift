// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftErrorDetection",
    targets: [
        .executableTarget(
            name: "SwiftErrorDetection",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftErrorDetectionTests",
            dependencies: ["SwiftErrorDetection"]
        ),
    ]
)