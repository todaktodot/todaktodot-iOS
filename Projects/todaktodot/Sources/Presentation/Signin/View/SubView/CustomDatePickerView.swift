//
//  CustomDatePickerView.swift
//  todaktodot
//
//  Created by 임대진 on 12/9/25.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift
import RxRelay

final class CustomDatePickerView: UIView {
    
    let isDateSelected = BehaviorRelay<String?>(value: nil)
    
    private let dateTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "YYYY-MM-DD",
            attributes: [.foregroundColor: UIColor.grayScale400]
        )
        $0.textColor = .grayScale900
        $0.tintColor = .clear
        $0.font = .pretenMedium(16)
    }

    private let disposeBag = DisposeBag()
    
    private let IconView = UIImageView().then {
        $0.image = UIImage(resource: .calendarGray)
    }

    private let pickerContainer = UIView().then {
        $0.backgroundColor = .white
    }

    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .inline
        $0.backgroundColor = .white
        $0.maximumDate = Date()
    }

    private let doneButton = UIButton(type: .system).then {
        $0.setTitle("확인", for: .normal)
        $0.tintColor = .black
        $0.titleLabel?.font = .pretenMedium(16)
        $0.isHidden = true
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
        let height: CGFloat = 380
        
        IconView.frame = CGRect(x: width - 80, y: 16, width: 24, height: 24)
        
        dateTextField.frame = CGRect(x: 20, y: 0, width: bounds.width - 40, height: 56)

        pickerContainer.frame = CGRect(x: 0, y: 0, width: width, height: height)

        doneButton.frame = CGRect(x: width - 80, y: 10, width: 80, height: 44)

        datePicker.frame = CGRect(x: 0, y: 44, width: width, height: height - 44)
    }
    
    func setDate(_ dateString: String) {
        guard let date = dateString.toDate() else { return }
        
        datePicker.setDate(date, animated: false)
        dateTextField.text = dateString
        IconView.image = UIImage(resource: .check)
        isDateSelected.accept(dateString)
    }

    private func setup() {
        dateTextField.inputView = pickerContainer
        backgroundColor = .white
        layer.cornerRadius = 8
        
        addSubview(IconView)
        addSubview(dateTextField)
        pickerContainer.addSubview(doneButton)
        pickerContainer.addSubview(datePicker)
    }

    private func bindAction() {
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        doneButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                IconView.image = UIImage(resource: .check)
                let selected = formatter.string(from: datePicker.date)
                self.setDate(selected)
                dateTextField.resignFirstResponder()
                doneButton.isHidden = true
            })
            .disposed(by: disposeBag)
        
        dateTextField.rx.text
            .subscribe(onNext: { [weak self] text in
                guard text != "" else { return }
                self?.isDateSelected.accept(text)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func dateChanged() {
        doneButton.isHidden = false
    }
}
