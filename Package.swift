// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SocialTodo",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/vapor-community/postgresql-provider.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "1.5.1"))
    ],
    targets: [
        .target(
            name: "App",
            dependencies: ["Vapor", "FluentProvider", "PostgreSQLProvider", "SwiftyBeaver"],
            exclude: ["Config", "Public", "Resources"]
        ),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)

