//
//  UIViewController +.swift
//  todaktodot
//
//  Created by 임대진 on 12/2/25.
//


import UIKit

extension UIViewController {
    func hideKeyboardwhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismisskeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
}
