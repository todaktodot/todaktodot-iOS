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
    let isPaste = BehaviorRelay<Bool>(value: false)
    
    private let hiddenTextField = UITextField().then {
        $0.keyboardType = .asciiCapable
        $0.autocorrectionType = .no
        $0.alpha = 0.01
    }
    
    private var codeBoxes: [CodeBoxView] = []
    
    init(frame: CGRect = .zero, isPartnerCode: Bool? = nil) {
        self.codeBoxes = (0..<6).map { _ in CodeBoxView() }
        super.init(frame: frame)
        
        if isPartnerCode != nil {
            setupHiddenTextField()
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
            addGestureRecognizer(tapGesture)
        }
        
        setupFlexLayout()
        setupLongPressGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCode() -> String {
        return hiddenTextField.text ?? ""
    }
    
    func setMyCodeStyle(_ code: String? = nil) {
        guard let code else { return }
        hiddenTextField.text = code
        updateBoxesState(isMyCode: code)
    }
    
    private func setupHiddenTextField() {
        addSubview(hiddenTextField)
        hiddenTextField.delegate = self
        hiddenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupFlexLayout() {
       flex.direction(.row).justifyContent(.spaceBetween).define {
            for box in codeBoxes {
                $0.addItem(box)
                    .width(44)
                    .height(48)
            }
        }
    }
    
    private func updateBoxesState(isMyCode: String? = nil) {
        if let code = isMyCode {
            print(code)
            for (i, char) in Array(code).enumerated() {
                codeBoxes[i].configure(char: char, isMyCode: true)
            }
        } else {
            let text = (hiddenTextField.text ?? "")
            hiddenTextField.text = text
            let chars = Array(text)
            
            for i in 0..<codeBoxes.count {
                if i < chars.count {
                    codeBoxes[i].configure(char: chars[i])
                } else {
                    codeBoxes[i].configure(char: nil)
                }
                
                if hiddenTextField.isFirstResponder {
                    if chars.count == 6 {
                        codeBoxes[i].setActive(i == 5)
                    } else {
                        codeBoxes[i].setActive(i == chars.count)
                    }
                } else {
                    codeBoxes[i].setActive(false)
                }
            }
            
            isCodeFull.accept(chars.count == 6)
        }
    }
    
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        hiddenTextField.becomeFirstResponder()
        
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.showMenu(from: self, rect: codeBoxes[0].frame)
        }
    }
    
    @objc private func viewTapped() {
        hiddenTextField.becomeFirstResponder()
    }
    
    @objc private func textFieldDidChange() {
        updateBoxesState()
    }
}

extension CodeTextFieldView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        let filteredString = string.components(separatedBy: allowed.inverted).joined()
        
        var updatedText: String
        
        if string.count > 1 {
            updatedText = String(filteredString.prefix(6)).uppercased()
            textField.endEditing(true)
        } else {
            guard let stringRange = Range(range, in: currentText) else { return false }
            updatedText = currentText.replacingCharacters(in: stringRange, with: filteredString).uppercased()
        }
        
        if updatedText.count >= 6 {
            updatedText = String(updatedText.prefix(6))
            textField.endEditing(true)
            isPaste.accept(true)
        }
        
        textField.text = updatedText
        
        updateBoxesState()
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateBoxesState()
    }
}
