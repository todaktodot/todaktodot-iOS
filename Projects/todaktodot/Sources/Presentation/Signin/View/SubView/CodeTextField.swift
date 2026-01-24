//
//  CodeTextField.swift
//  todaktodot
//
//  Created by 임대진 on 12/2/25.
//

import UIKit

final class CodeTextField: UITextField {
    var previousTextField: UITextField?
    var nextTextField: UITextField?
    
    init(frame: CGRect = .zero, char: String? = nil) {
        super.init(frame: frame)
        
        self.isEnabled = char == nil
        self.text = char ?? ""
        self.tintColor = .mainPurple
        self.textColor = .mainPurple
        self.textAlignment = .center
        self.font = .pretenMedium(24)
        self.backgroundColor = char == nil ? .white : .lightPurple
        self.layer.cornerRadius = 6
        self.layer.borderWidth = char == nil ? 1 : 0
        self.layer.borderColor = UIColor.grayScale200.cgColor
        self.keyboardType = .asciiCapable
        self.autocapitalizationType = .allCharacters
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        if let text = self.text, !text.isEmpty {
            self.text?.removeAll()
        } else if let previous = previousTextField {
            previous.text = ""
            previous.becomeFirstResponder()
        } else {
            super.deleteBackward()
        }
    }
}
