//
//  GoogleAuthProvider.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import GoogleSignIn

final class GoogleAuthProvider {
    func login() -> Observable<GIDSignInResult> {
        return Observable.create { observer in
            guard let rootViewController = UIApplication.shared.currentRootViewController else {
                observer.onError(
                    NSError(
                        domain: "GoogleSignIn",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No root view controller available"]
                    )
                )
                return Disposables.create()
            }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                if let error = error {
                    observer.onError(error)
                } else if let result = signInResult {
                    observer.onNext(result)
                    observer.onCompleted()
                } else {
                    observer.onError(
                        NSError(
                            domain: "GoogleSignIn",
                            code: -2,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown sign-in error"]
                        )
                    )
                }
            }

            return Disposables.create()
        }
    }
}
