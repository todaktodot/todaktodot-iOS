//
//  UIViewController +.swift
//  todaktodot
//
//  Created by 임대진 on 12/2/25.
//


import UIKit
import FlexLayout
import PinLayout

extension UIViewController {
    func hideKeyboardwhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismisskeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    
    func showToast(message: String, duration: TimeInterval = 2.0) {
        guard let windowScene = UIApplication.shared.connectedScenes
               .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                 let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let backgroundView = UIView().then {
            $0.backgroundColor = .grayScale800.withAlphaComponent(0.95)
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            $0.alpha = 0
        }

        let toastLabel = UILabel().then {
            $0.text = message
            $0.textColor = .white
            $0.textAlignment = .left
            $0.font = .pretenRegular(14)
        }
        
        window.addSubview(backgroundView)
        
        backgroundView.pin
            .left(16)
            .right(16)
            .bottom(window.safeAreaInsets.bottom + 16)
            .height(48)
        
        backgroundView.flex.direction(.row).alignItems(.center).define {
            $0.addItem(toastLabel)
                .marginLeft(20)
        }
        
        backgroundView.flex.layout()

        UIView.animate(withDuration: 0.3) {
            backgroundView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut) {
                backgroundView.alpha = 0
            } completion: { _ in
                backgroundView.removeFromSuperview()
            }
        }
    }

}
