import ProjectDescription

let googleServiceInfoScript = TargetScript.post(
    script: """
    case "${CONFIGURATION}" in
      "Debug" )
        cp -r "$SRCROOT/Resources/GoogleService-Info-Debug.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" ;;
      "Release" )
        cp -r "$SRCROOT/Resources/GoogleService-Info-Release.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist" ;;
    *)
      ;;
    esac
    """,
    name: "Setup Firebase Environment GoogleService-info.plist",
    basedOnDependencyAnalysis: false
)

let project = Project(
    name: "todaktodot",
    options: .options(
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
    ),
    targets: [
        .target(
            name: "todaktodot",
            destinations: [.iPhone],
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1",
                    "UIUserInterfaceStyle": "Light",
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ],
                            ]
                        ]
                    ],
                    "LSApplicationQueriesSchemes" : [
                        "kakaokompassauth",
                        "kakaolink",
                        "kakaoplus",
                        "kakaotalk",
                        "todaktodot"
                    ],
                    "CFBundleURLTypes" : [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["$(KAKAO_URL_KEY)"]
                        ],
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["$(GOOGLE_URL_KEY)"]
                        ],
                    ],
                    "CFBundleDisplayName" : "투닥투닷",
                    "KAKAO_URL_KEY": "$(KAKAO_URL_KEY)",
                    "KAKAO_APP_KEY": "$(KAKAO_APP_KEY)",
                    "TODAKTODOT_API": "$(TODAKTODOT_API)",
                    "TODAKTODOT_DEV_API": "$(TODAKTODOT_DEV_API)",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "ITSAppUsesNonExemptEncryption" : false,
                ]
            ),
            sources: ["Sources/**"],
            resources: [
                "Resources/**",
                "Sources/App/LaunchScreen.storyboard",
            ],
            entitlements: "todaktodot.entitlements",
            scripts: [googleServiceInfoScript],
            dependencies: [
                .external(name: "Alamofire"),
                .external(name: "Then"),
                .external(name: "ReactorKit"),
                .external(name: "RxSwift"),
                .external(name: "RxCocoa"),
                .external(name: "RxKakaoSDK"),
                .external(name: "FirebaseCrashlytics"),
                .external(name: "FirebaseDynamicLinks"),
                .external(name: "FirebaseMessaging"),
                .external(name: "FirebasePerformance"),
                .external(name: "FirebaseRemoteConfig"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FlexLayout"),
                .external(name: "PinLayout"),
                .external(name: "Lottie"),
                .project(target: "NetworkKit", path: "../NetworkKit"),
                .target(name: "SharedLibraries")
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS":["-all_load -Objc"],
                    "DEVELOPMENT_TEAM": "5HY2NNF4HY",
                    "CODE_SIGN_STYLE": "Manual",
                    "CODE_SIGN_IDENTITY": "Apple Distribution",
                    "VERSIONING_SYSTEM": "apple-generic",
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0.0"
                ],
                configurations: [
                    .debug(name: "Debug", xcconfig: "Config/Debug.xcconfig"),
                    .release(name: "Release", xcconfig: "Config/Release.xcconfig")
                ]
            )
        ),
        .target(
            name: "todaktodotTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.tuist.todaktodotTests",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "todaktodot")]
        ),
        .target(
            name: "SharedLibraries",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.todaktodot.SharedLibraries",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: [],
            dependencies: [
                .external(name: "FirebaseAuth"),
                .external(name: "GoogleSignIn"),
            ]
        ),
    ]
)

