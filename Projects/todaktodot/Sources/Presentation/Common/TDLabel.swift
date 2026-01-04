//
//  TDLabel.swift
//  todaktodot
//
//  Created by 임대진 on 1/4/26.
//

import UIKit

final class TDLabel: UILabel {
    var lineHeightMultiplier: CGFloat = 1.26 {
        didSet { applyLineHeight() }
    }

    override var text: String? {
        didSet { applyLineHeight() }
    }

    override var font: UIFont! {
        didSet { applyLineHeight() }
    }

    override var textAlignment: NSTextAlignment {
        didSet { applyLineHeight() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyLineHeight()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyLineHeight()
    }

    private func applyLineHeight() {
        guard let text = self.text, !text.isEmpty else { return }
        guard let font = self.font else { return }

        let size = font.lineHeight * lineHeightMultiplier

        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = size
        style.maximumLineHeight = size
        style.alignment = self.textAlignment

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: style,
            .baselineOffset: (size - font.lineHeight) / 2
        ]

        super.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
