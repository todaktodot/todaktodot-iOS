//
//  DateTextFieldView.swift
//  todaktodot
//
//  Created by 임대진 on 7/1/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift
import RxRelay

final class DateTextFieldView: UIView, UITextFieldDelegate {
    let currentDate = BehaviorRelay<String?>(value: nil)
    let isCorrectDate = BehaviorRelay<Bool>(value: false)
    let hiddenWarning = PublishRelay<Bool>()
    
    let backgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale200.cgColor
    }
    
    let dateTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "YYYY-MM-DD",
            attributes: [.foregroundColor: UIColor.grayScale400]
        )
        $0.textColor = .grayScale900
        $0.font = .pretenMedium(16)
    }
    
    let warningLabel = UILabel().then {
        $0.textColor = .redErrorColor
        $0.font = .pretenMedium(12)
        $0.text = "앗, 생년월일을 다시 확인해 주세요"
        $0.flex.display(.none)
        $0.alpha = 0
    }
    
    private let disposeBag = DisposeBag()

    private let IconView = UIImageView()

    init() {
        super.init(frame: .zero)
        setup()
        setupFlexLayout()
        bindAction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(IconView)
        addSubview(dateTextField)
    }
    
    private func setupFlexLayout() {
        flex.define {
            $0.addItem(backgroundView).direction(.row).define {
                $0.addItem(dateTextField)
                    .grow(1)
                    .height(56)
                    .marginLeft(16)
                
                $0.addItem(IconView)
                    .size(24)
                    .marginRight(16)
                    .marginTop(16)
            }
            
            $0.addItem(warningLabel)
                .marginTop(8)
                .marginLeft(8)
                .height(18)
        }
    }

    private func bindAction() {
        dateTextField.rx.controlEvent(.editingChanged)
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                self.formatAndValidate()
            })
            .disposed(by: disposeBag)
        
        dateTextField.rx.text
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                currentDate.accept(text)
            })
            .disposed(by: disposeBag)
    }

    private func formatAndValidate() {
        let raw = dateTextField.text ?? ""

        let digits = String(raw.filter { $0.isNumber }.prefix(8))

        var result = digits
        if digits.count > 4 {
            let start = digits.prefix(4)
            let middle = digits.dropFirst(4).prefix(2)
            let end = digits.dropFirst(6).prefix(2)

            result = start + (middle.isEmpty ? "" : "-\(middle)") + (end.isEmpty ? "" : "-\(end)")
        }

        if dateTextField.text != result {
            dateTextField.text = result
        }
        
        let validateDate = validateDate(digits)
        
        isCorrectDate.accept(validateDate)
        
        if digits.count == 8 {
            IconView.image = validateDate ? UIImage(resource: .check) : UIImage(resource: .warningRed)
            hiddenWarning.accept(validateDate)
            IconView.isHidden = false
        } else {
            hiddenWarning.accept(true)
            IconView.isHidden = true
        }
    }

    private func validateDate(_ digits: String) -> Bool {
        guard digits.count == 8 else {
            return false
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = formatter.date(from: digits) else {
            return false
        }

        let year = Int(String(digits.prefix(4))) ?? 0

        guard year >= 1900 else { return false }

        let today = Date()
        guard date <= today else { return false }

        return true
    }
}
