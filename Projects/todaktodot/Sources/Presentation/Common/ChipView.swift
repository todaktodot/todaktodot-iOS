//
//  ChipView.swift
//  todaktodot
//
//  Created by daye on 2/11/26.
//

import UIKit

final class ChipView: UIView {
    
    private let label = TDLabel()
    private var calculatedWidth: CGFloat = 0
    
    init(title: String) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayScale200.cgColor
        layer.cornerRadius = 18.5
        
        label.text = title
        label.font = .pretenMedium(14)
        label.textColor = .grayScale800
        label.sizeToFit()
        
        calculatedWidth = label.frame.width + 28
        
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTitle(_ title: String) {
        label.text = title
        label.sizeToFit()
        calculatedWidth = label.frame.width + 28
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
    func setHighlighted(_ highlighted: Bool) {
        layer.borderColor = highlighted ? UIColor.mainPurple.cgColor : UIColor.grayScale200.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.pin.center()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: calculatedWidth, height: 37)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: calculatedWidth, height: 37)
    }
}
