import ProjectDescription

let NetworkKit = Project(
    name: "NetworkKit",
    targets: [
        .target(
            name: "NetworkKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.todaktodot.NetworkKit",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "todaktodotAPI": "$(_TODAKTODOT_API_)"
                ]
            ),
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "Alamofire"),
                .external(name: "RxSwift"),
                .external(name: "RxCocoa")
            ]
        ),
        .target(
            name: "NetworkKitTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.todaktodot.NetworkKitTests",
            infoPlist: .default,
            sources: ["NetworkKitTests/**"],
            resources: [],
            dependencies: [
                .target(name: "NetworkKit")
            ]
        ),
    ]
)
