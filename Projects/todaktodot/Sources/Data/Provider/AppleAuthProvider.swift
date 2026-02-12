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

final class AppleAuthProvider {
    
    private var currentDelegate: AppleAuthorizationDelegate?
    
    func login() -> Observable<String> {
        return Observable.create { [weak self] observer in
            guard self != nil else {
                observer.onError(NSError(domain: "AppleLogin", code: -1))
                return Disposables.create()
            }

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()

            let controller = ASAuthorizationController(authorizationRequests: [request])

            let delegate = AppleAuthorizationDelegate(
                onSuccess: { [weak self] credential in
                    guard let self else { return }
                    guard let authorizationCode = credential.authorizationCode,
                          let code = String(data: authorizationCode, encoding: .utf8) else {
                        observer.onError(NSError(domain: "AppleLogin", code: -2))
                        return
                    }
                    observer.onNext(code)
                    observer.onCompleted()
                    self.currentDelegate = nil
                },
                onError: { [weak self] error in
                    observer.onError(error)
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

    init(
        onSuccess: @escaping (ASAuthorizationAppleIDCredential) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
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
            return
        }
        onError(error)
    }
}
