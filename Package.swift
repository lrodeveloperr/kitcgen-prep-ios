// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KitchenPrepBoardUI",
    platforms: [.iOS(.v16)],
    products: [.library(name: "KitchenPrepBoardUI", targets: ["KitchenPrepBoardUI"])],
    targets: [
        .target(
            name: "KitchenPrepBoardUI",
            path: "Sources/KitchenPrepBoardUI",
            resources: [.process("Resources")]
        )
    ]
)
