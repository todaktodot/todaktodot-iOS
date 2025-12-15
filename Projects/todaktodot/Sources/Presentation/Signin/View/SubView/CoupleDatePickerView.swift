//
//  CoupleDatePickerView.swift
//  todaktodot
//
//  Created by 임대진 on 12/9/25.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift

class CoupleDatePickerView: UIView {

    let dateTextField = UITextField().then {
        $0.attributedPlaceholder = NSAttributedString(
            string: "YY-MM-DD",
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
    }

    private let doneButton = UIButton(type: .system).then {
        $0.setTitle("확인", for: .normal)
        $0.tintColor = .black
        $0.titleLabel?.font = .pretenMedium(16)
    }

    init() {
        super.init(frame: .zero)
        setup()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        dateTextField.inputView = pickerContainer
        
        addSubview(IconView)
        addSubview(dateTextField)
        pickerContainer.addSubview(doneButton)
        pickerContainer.addSubview(datePicker)
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

    private func bind() {
        doneButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                IconView.image = UIImage(resource: .check)
                dateTextField.text = formatter.string(from: datePicker.date)
                dateTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
}
