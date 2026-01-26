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
    private let horizonPadding: CGFloat
    private let verticalPadding: CGFloat
    private var imageFirst: Bool

    init(frame: CGRect = .zero, horizonPadding: CGFloat? = nil, verticalPadding: CGFloat? = nil, spacing: CGFloat? = nil, imageSize: CGFloat, imageFirst: Bool = true) {
        
        self.spacing = spacing ?? 2
        self.imageSize = imageSize
        self.horizonPadding = horizonPadding ?? 12
        self.verticalPadding = verticalPadding ?? 8
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
        self.flex.direction(.row).alignItems(.center).paddingVertical(verticalPadding).paddingHorizontal(horizonPadding).define { flex in
            
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

