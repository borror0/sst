// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "FinanceApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FinanceApp",
            targets: ["FinanceApp"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FinanceApp",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .testTarget(
            name: "FinanceAppTests",
            dependencies: ["FinanceApp"]
        ),
    ]
)