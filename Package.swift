// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Woodwork",
    platforms: [.macOS(.v14)],
    products: [
        // Lowercase executable names so each project runs as `swift run caddy`.
        .executable(name: "caddy", targets: ["Caddy"]),
    ],
    dependencies: [
        // see https://github.com/tomasf/Cadova
        .package(url: "https://github.com/tomasf/Cadova.git", exact: "0.8.1"),
        // see https://github.com/tomasf/Helical
        .package(url: "https://github.com/tomasf/Helical.git", exact: "1.0.3"),
    ],
    targets: [
        // Shared modelling library: gear models used for scale and fit-checking,
        // hardware (casters, screws), and the cutlist/screw-list/SVG output helpers.
        // Cadova wraps the C++ Manifold kernel, so every target that touches it
        // needs Cxx interop — it does not propagate across a module boundary.
        .target(
            name: "Woodwork",
            dependencies: ["Cadova", "Helical"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        // One executable target per project.
        .executableTarget(
            name: "Caddy",
            dependencies: ["Woodwork", "Cadova", "Helical"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
