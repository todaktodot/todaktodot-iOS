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
    
    private let dateTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "YYYY-MM-DD",
            attributes: [.foregroundColor: UIColor.grayScale400]
        )
        $0.textColor = .grayScale900
        $0.tintColor = .clear
        $0.font = .pretenMedium(16)
        $0.keyboardType = .numberPad
    }

    private let disposeBag = DisposeBag()
    
    private let IconView = UIImageView().then {
        $0.image = UIImage(resource: .calendarGray)
    }

    init() {
        super.init(frame: .zero)
        setup()
        bindAction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let width = UIScreen.main.bounds.width
        IconView.frame = CGRect(x: width - 80, y: 16, width: 24, height: 24)
        dateTextField.frame = CGRect(x: 20, y: 0, width: bounds.width - 40, height: 56)
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 8
        
        addSubview(IconView)
        addSubview(dateTextField)
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
        
        IconView.image = UIImage(resource: validateDate ? .check : .calendarGray)
        isCorrectDate.accept(validateDate)
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
