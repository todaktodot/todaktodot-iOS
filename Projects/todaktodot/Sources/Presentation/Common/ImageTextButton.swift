//
//  ImageTextButton.swift
//  imdang
//
//  Created by 임대진 on 12/16/24.
//

import UIKit
import Then
import FlexLayout
import PinLayout

final class ImageTextButton: UIButton {
    let customImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    let customText = TDLabel()
    
    private let spacing: CGFloat
    private let imageSize: CGFloat
    private let textLabelWidth: CGFloat?
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    private let leftPadding: CGFloat
    private let rightPadding: CGFloat
    private var imageFirst: Bool

    init(
        frame: CGRect = .zero,
        horizonPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        topPadding: CGFloat? = nil,
        bottomPadding: CGFloat? = nil,
        leftPadding: CGFloat? = nil,
        rightPadding: CGFloat? = nil,
        textLabelWidth: CGFloat? = nil,
        spacing: CGFloat? = nil,
        imageSize: CGFloat,
        imageFirst: Bool = true
    ) {
        
        self.spacing = spacing ?? 2
        self.imageSize = imageSize
        self.topPadding = topPadding ?? (verticalPadding ?? 8)
        self.bottomPadding = bottomPadding ?? (verticalPadding ?? 8)
        self.leftPadding = leftPadding ?? (horizonPadding ?? 12)
        self.rightPadding = rightPadding ?? (horizonPadding ?? 12)
        self.textLabelWidth = textLabelWidth
        self.imageFirst = imageFirst
        
        super.init(frame: frame)
        
        setupViews()
        setupFlexLayout()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.addSubview(customImage)
        self.addSubview(customText)
    }
    
    private func setupFlexLayout() {
        if let textLabelWidth {
            customText.flex.width(textLabelWidth)
        }
        self.flex
            .direction(.row)
            .alignItems(.center)
            .paddingTop(topPadding)
            .paddingBottom(bottomPadding)
            .paddingLeft(leftPadding)
            .paddingRight(rightPadding)
            .define { flex in
            
            if imageFirst {
                flex.addItem(customImage).size(imageSize).marginRight(spacing)
                flex.addItem(customText)
            } else {
                flex.addItem(customText)
                flex.addItem(customImage).size(imageSize).marginLeft(spacing)
            }
        }
    }
    
    private func layoutViews() {
        self.flex.layout()
    }
}
