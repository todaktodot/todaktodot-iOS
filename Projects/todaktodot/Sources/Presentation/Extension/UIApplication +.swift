//
//  UIApplication +.swift
//  imdang
//
//  Created by 임대진 on 11/27/24.
//

import UIKit

extension UIApplication {
    /// 활성화된 첫 번째 UIWindowScene을 찾음
    var currentRootViewController: UIViewController? {
        guard let windowScene = connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                return nil
        }
        
        return windowScene.windows.first?.rootViewController
    }
}
