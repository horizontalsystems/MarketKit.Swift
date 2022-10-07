// swift-tools-version:5.5

import PackageDescription

let package = Package(
        name: "MarketKit",
        platforms: [
          .iOS(.v13),
        ],
        products: [
          .library(
                  name: "MarketKit",
                  targets: ["MarketKit"]
          ),
        ],
        dependencies: [
          .package(url: "https://github.com/groue/GRDB.swift.git", .upToNextMajor(from: "5.0.0")),
          .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.1.0")),
          .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.1")),
          .package(url: "https://github.com/horizontalsystems/HsToolKit.Swift.git", .upToNextMajor(from: "1.0.0")),
          .package(url: "https://github.com/horizontalsystems/HsExtensions.Swift.git", .upToNextMajor(from: "1.0.0")),
        ],
        targets: [
          .target(
                  name: "MarketKit",
                  dependencies: [
                    .product(name: "GRDB", package: "GRDB.swift"),
                    "ObjectMapper",
                    "RxSwift",
                    .product(name: "RxRelay", package: "RxSwift"),
                    .product(name: "HsToolKit", package: "HsToolKit.Swift"),
                    .product(name: "HsExtensions", package: "HsExtensions.Swift"),
                  ],
                  resources: [
                      .copy("Dumps")
                  ]
          )
        ]
)
