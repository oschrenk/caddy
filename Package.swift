// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "caddy",
    platforms: [.macOS(.v14)],
    dependencies: [
        // see https://github.com/tomasf/Cadova
        .package(url: "https://github.com/tomasf/Cadova.git", exact: "0.7.0"),
        // see https://github.com/tomasf/Helical
        .package(url: "https://github.com/tomasf/Helical.git", exact: "1.0.2"),
    ],
    targets: [
        .executableTarget(
            name: "caddy",
            dependencies: ["Cadova", "Helical"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
