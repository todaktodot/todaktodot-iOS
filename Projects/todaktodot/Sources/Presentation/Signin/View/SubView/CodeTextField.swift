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
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.tintColor = .mainPurple
        self.textColor = .mainPurple
        self.textAlignment = .center
        self.font = .pretenMedium(24)
        self.backgroundColor = .white
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 1
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
    
    func setMyCodeStyle(char: String) {
        self.isEnabled = false
        self.backgroundColor = .lightPurple
        self.layer.borderWidth = 0
        self.text = char
    }
}
