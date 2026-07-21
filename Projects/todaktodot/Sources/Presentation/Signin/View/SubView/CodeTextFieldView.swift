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
    
    private var codeBoxes: [CodeBoxView] = []
    
    override init(frame: CGRect = .zero) {
        self.codeBoxes = (0..<6).map { _ in CodeBoxView() }
        super.init(frame: frame)
        setupFlexLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCode() -> String {
        return codeBoxes.compactMap { $0.textField.text }.joined()
    }
    
    func setMyCodeStyle(_ code: String? = nil) {
        guard let code else { return }
        for (i, char) in Array(code).enumerated() {
            if i < codeBoxes.count {
                codeBoxes[i].configure(char: char, isMyCode: true)
            }
        }
        updateBoxesState(isMyCode: code)
    }
    
    private func setupFlexLayout() {
       flex.direction(.row).justifyContent(.spaceBetween).define {
            for (index, box) in codeBoxes.enumerated() {
                let tf = box.textField
                tf.tag = index
                tf.delegate = self
                tf.addTarget(self, action: #selector(handleEditingChanged(_:)), for: .editingChanged)
                tf.onDeleteBackward = { [weak self] in
                    guard let self else { return }
                    let index = tf.tag
                    if index > 0 {
                        let prev = self.codeBoxes[index - 1].textField
                        prev.text = ""
                        prev.becomeFirstResponder()
                        self.updateBoxesState()
                    }
                }
                $0.addItem(box)
                    .width(44)
                    .height(48)
            }
        }
    }
    
    private func updateBoxesState(isMyCode: String? = nil) {
        let textArray = codeBoxes.compactMap { $0.textField.text }.joined()
        
        for box in codeBoxes {
            box.setActive(box.textField.isFirstResponder)
        }
        
        isCodeFull.accept(textArray.count == 6)
    }
    
    @objc private func handleEditingChanged(_ textField: UITextField) {
        updateBoxesState()
    }
}

extension CodeTextFieldView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        let filtered = string.components(separatedBy: allowed.inverted).joined().uppercased()
        
        if filtered.isEmpty && !string.isEmpty {
            return false
        }
        
        // 붙여넣기
        if filtered.count > 1 {
            let chars = Array(filtered.prefix(codeBoxes.count))
            
            for (i, char) in chars.enumerated() {
                codeBoxes[i].textField.text = String(char)
            }
            
            endEditing(true)
            
            updateBoxesState()
            return false
        }
        
        if string.isEmpty {
            textField.text = ""
            
            updateBoxesState()
            return false
        }
        
        let index = textField.tag
        textField.text = String(filtered.prefix(1))
        
        if index < codeBoxes.count - 1 {
            codeBoxes[index + 1].textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        updateBoxesState()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateBoxesState()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateBoxesState()
    }
}
