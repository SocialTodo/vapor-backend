// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SocialTodo",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "3.0.0-rc")),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc"),
        //.package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "3.0.0-rc")),
        //.package(url: "https://github.com/vapor-community/postgresql-provider.git", .upToNextMajor(from: "3.0.0-rc")),
        //.package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "1.5.1"))
    ],
    targets: [
        .target(
            name: "App",
            dependencies: ["Vapor", "FluentSQLite"],
            exclude: ["Config", "Public", "Resources"]
        ),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

