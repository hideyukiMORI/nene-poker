// swift-tools-version: 6.2
// tools-version は manifest の API の版であり、ツールチェーンの版（.swift-version）ではない。
// 6.2 は treatAllWarnings(as:) を使える最小の版（ADR 0001）。
// target は承認された依存グラフ（docs/architecture/module-graph.txt・ADR 0004）から、最初の責務が生じた PR で足す（Core は Issue #3、ほかは Issue #7）。
// 各 target の swiftSettings は [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]（CNF-009）。

import PackageDescription

let package = Package(
    name: "NeNePoker",
    targets: [
        .target(
            name: "NeNePokerCore",
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .target(
            name: "NeNePokerEngine",
            dependencies: ["NeNePokerCore"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .target(
            name: "NeNePokerRender",
            dependencies: ["NeNePokerCore", "NeNePokerEngine"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .target(
            name: "NeNePokerTerminal",
            dependencies: ["NeNePokerRender"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .executableTarget(
            name: "nene-poker",
            dependencies: ["NeNePokerCore", "NeNePokerEngine", "NeNePokerRender", "NeNePokerTerminal"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNePokerCoreTests",
            dependencies: ["NeNePokerCore"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNePokerEngineTests",
            dependencies: ["NeNePokerCore", "NeNePokerEngine"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNePokerRenderTests",
            dependencies: ["NeNePokerCore", "NeNePokerEngine", "NeNePokerRender"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNePokerTerminalTests",
            dependencies: ["NeNePokerRender", "NeNePokerTerminal"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
