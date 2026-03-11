// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlaschenTaschenClients",
    platforms: [.macOS(.v15)],
    products: [
        // Library
        .library(name: "FlaschenTaschenClientKit", targets: ["FlaschenTaschenClientKit"]),

        .executable(name: "send-text", targets: ["send-text"]),
        .executable(name: "send-image", targets: ["send-image"]),
        .executable(name: "send-video", targets: ["send-video"]),
    ],
    targets: [
        // FlaschenTaschenClientKit Library
        .target(name: "FlaschenTaschenClientKit"),

        // Clients
        .executableTarget(name: "send-text", dependencies: ["FlaschenTaschenClientKit"]),
        .executableTarget(name: "send-image", dependencies: ["FlaschenTaschenClientKit"]),
        .executableTarget(name: "send-video", dependencies: ["FlaschenTaschenClientKit"]),
    ]
)
