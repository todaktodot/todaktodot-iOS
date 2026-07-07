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

let crashlyticsScript = TargetScript.post(
    script: """
    ROOT_DIR=$(git rev-parse --show-toplevel)
    "${ROOT_DIR}/Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
    """,
    name: "Firebase Crashlytics dSYM Upload",
    inputPaths: [
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
        "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
        "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"
    ],
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
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["todaktodot"]
                        ],
                    ],
                    "CFBundleDisplayName" : "투닥투닷",
                    "KAKAO_URL_KEY": "$(KAKAO_URL_KEY)",
                    "KAKAO_APP_KEY": "$(KAKAO_APP_KEY)",
                    "TODAKTODOT_API": "$(TODAKTODOT_API)",
                    "TODAKTODOT_DEV_API": "$(TODAKTODOT_DEV_API)",
                    "DISCORD_WEBHOOK_URL": "$(DISCORD_WEBHOOK_URL)",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "ITSAppUsesNonExemptEncryption" : false,
                    "NSPhotoLibraryAddUsageDescription": "데일리카드를 사진첩에 저장하기 위해 접근 권한이 필요합니다.",
                    "UIBackgroundModes": [
                        "remote-notification"
                    ],
                ]
            ),
            sources: ["Sources/**"],
            resources: [
                "Resources/**",
                "Sources/App/LaunchScreen.storyboard",
            ],
            entitlements: "todaktodot.entitlements",
            scripts: [googleServiceInfoScript, crashlyticsScript],
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
                    "VERSIONING_SYSTEM": "apple-generic",
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0.0",
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
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

