// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Pedometer",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Pedometer",
            targets: ["PedometerPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "PedometerPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/PedometerPlugin"),
        .testTarget(
            name: "PedometerPluginTests",
            dependencies: ["PedometerPlugin"],
            path: "ios/Tests/PedometerPluginTests")
    ]
)