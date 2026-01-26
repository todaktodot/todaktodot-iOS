// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [
            "Alamofire": .framework,
            "Then": .framework,
            "ReactorKit": .framework,
            "RxSwift": .framework,
            "RxCocoa": .framework,
            "RxKakaoSDK": .framework,
            "SharedLibraries": .framework,
            "FlexLayout": .staticFramework,
            "PinLayout": .framework,
            "Lottie": .framework,
            "firebase-ios-sdk": .framework
        ]
    )
#endif

let package = Package(
    name: "todaktodot",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        .package(url: "https://github.com/devxoul/Then", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/ReactorKit/ReactorKit.git", .upToNextMinor(from: "3.2.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMinor(from: "6.8.0")),
        .package(url: "https://github.com/kakao/kakao-ios-sdk-rx", .upToNextMinor(from: "2.23.0")),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .upToNextMinor(from: "2.23.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMinor(from: "11.7.0")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", .upToNextMinor(from: "8.0.0")),
        .package(url: "https://github.com/layoutBox/FlexLayout", .upToNextMinor(from: "2.2.2")),
        .package(url: "https://github.com/layoutBox/PinLayout", .upToNextMinor(from: "1.10.6")),
        .package(url: "https://github.com/airbnb/lottie-ios", .upToNextMinor(from: "4.6.0")),
    ]
)

