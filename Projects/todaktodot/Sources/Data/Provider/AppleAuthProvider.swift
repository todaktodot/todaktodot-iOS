//
//  AppleAuthProvider.swift
//  todaktodot
//
//  Created by 임대진 on 2/13/26.
//

import Foundation
import AuthenticationServices
import RxSwift

import NetworkKit

struct AppleLoginResult {
    let authorizationCode: String
    let appName: String?
}

final class AppleAuthProvider {
    private var currentDelegate: AppleAuthorizationDelegate?
    
    func login() -> Observable<AppleLoginResult> {
        return Observable.create { [weak self] observer in
            guard self != nil else {
                observer.onError(NSError(domain: "AppleLogin", code: -1))
                return Disposables.create()
            }

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName]

            let controller = ASAuthorizationController(authorizationRequests: [request])

            let delegate = AppleAuthorizationDelegate(
                onSuccess: { [weak self] credential in
                    guard let self else { return }
                    guard let authorizationCode = credential.authorizationCode,
                          let code = String(data: authorizationCode, encoding: .utf8) else {
                        observer.onError(NSError(domain: "AppleLogin", code: -2))
                        return
                    }

                    let fullName = [
                        credential.fullName?.familyName,
                        credential.fullName?.givenName
                    ]
                    .compactMap { $0 }
                    .joined(separator: "")

                    observer.onNext(
                        AppleLoginResult(
                            authorizationCode: code,
                            appName: fullName.isEmpty ? nil : fullName
                        )
                    )
                    observer.onCompleted()
                    self.currentDelegate = nil
                },
                onError: { [weak self] error in
                    observer.onError(error)
                    self?.currentDelegate = nil
                },
                canceled: {
                    observer.onCompleted()
                    self?.currentDelegate = nil
                }
            )
            self?.currentDelegate = delegate

            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()

            return Disposables.create()
        }
    }
}

private final class AppleAuthorizationDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let onSuccess: (ASAuthorizationAppleIDCredential) -> Void
    private let onError: (Error) -> Void
    private let canceled: () -> Void

    init(
        onSuccess: @escaping (ASAuthorizationAppleIDCredential) -> Void,
        onError: @escaping (Error) -> Void,
        canceled: @escaping () -> Void
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
        self.canceled = canceled
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            onSuccess(credential)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let nsError = error as NSError
        if nsError.domain == ASAuthorizationError.errorDomain &&
            nsError.code == ASAuthorizationError.canceled.rawValue {
            canceled()
        }
        onError(error)
    }
}
