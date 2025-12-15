//
//  PaddingButton.swift
//  todaktodot
//
//  Created by 임대진 on 12/12/25.
//

import UIKit
import FlexLayout
import PinLayout

final class PaddingButton: UIButton {
    let textLabel = UILabel()
    let padding: CGFloat

    init(frame: CGRect = .zero, padding: CGFloat = 16, text: String) {
        self.padding = padding
        
        self.textLabel.text = text
        self.textLabel.font = .pretenMedium(16)
        self.textLabel.textColor = .grayScale900
        
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.pin.left(padding).top().bottom().right()
    }
    
    func setupUI() {
        self.addSubview(textLabel)
    }
}
