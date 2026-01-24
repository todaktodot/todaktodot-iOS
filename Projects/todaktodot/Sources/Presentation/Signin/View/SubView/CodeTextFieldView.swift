//
//  CodeTextFieldView.swift
//  todaktodot
//
//  Created by 임대진 on 12/2/25.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxRelay

final class CodeTextFieldView: UIView {
    let isCodeFull = PublishRelay<Bool>()
    
    private var codeTextFields: [UITextField]
    
    init(frame: CGRect = .zero, code: [String]? = nil) {
        
        if let code = code {
            self.codeTextFields = code.map { CodeTextField(char: $0.uppercased()) }
        } else {
            self.codeTextFields = (0..<6).map { _ in CodeTextField() }
        }
        
        super.init(frame: frame)
        
        for i in 0..<codeTextFields.count {
            let current = codeTextFields[i] as? CodeTextField
            current?.delegate = self
            
            if i > 0 {
                current?.previousTextField = codeTextFields[i - 1]
            }
            
            if i < codeTextFields.count - 1 {
                current?.nextTextField = codeTextFields[i + 1]
            }
        }
        
        setupFlexLayout()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFlexLayout() {
        self.flex.direction(.row).justifyContent(.spaceBetween).define { codeFlex in
            
            for textField in codeTextFields {
                codeFlex.addItem(textField).width(44).height(48)
            }
        }
    }
    
    private func layoutViews() {
        self.flex.layout()
    }
}

extension CodeTextFieldView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let uppercased = string.uppercased()

        let allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        let allowedSet = CharacterSet(charactersIn: allowed)

        guard uppercased.rangeOfCharacter(from: allowedSet.inverted) == nil else {
            return false
        }
        
        textField.text = String(uppercased.prefix(1))
        
        if textField.text != "" {
            if (textField as? CodeTextField)?.nextTextField == nil {
                endEditing(true)
            } else {
                (textField as? CodeTextField)?.nextTextField?.becomeFirstResponder()
            }
        }
        
        if codeTextFields.filter({ $0.text != "" }).count >= 6 {
            isCodeFull.accept(true)
        } else {
            isCodeFull.accept(false)
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.mainPurple.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.grayScale200.cgColor
    }
}
