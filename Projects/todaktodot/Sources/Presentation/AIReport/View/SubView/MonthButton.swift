//
//  MonthButton.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//

import UIKit

final class MonthButton: UIButton {
    let month: Int

    init(month: Int) {
        self.month = month
        super.init(frame: .zero)
        setTitle(String(month) + "월", for: .normal)
        titleLabel?.font = .pretenSemiBold(14)

        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        backgroundColor = .white
        setTitleColor(.grayScale400, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func update(selected: Int) {
        if month == selected {
            backgroundColor = .mainPurple
            setTitleColor(.white, for: .normal)
        } else {
            backgroundColor = .white
            setTitleColor(.grayScale400, for: .normal)
        }
    }
}
