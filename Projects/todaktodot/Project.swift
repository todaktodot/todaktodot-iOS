import ProjectDescription

let project = Project(
    name: "todaktodot",
    targets: [
        .target(
            name: "todaktodot",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.todaktodot",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["todaktodot/Sources/**"],
            resources: ["todaktodot/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "todaktodotTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.todaktodotTests",
            infoPlist: .default,
            sources: ["todaktodot/Tests/**"],
            resources: [],
            dependencies: [.target(name: "todaktodot")]
        ),
    ]
)
