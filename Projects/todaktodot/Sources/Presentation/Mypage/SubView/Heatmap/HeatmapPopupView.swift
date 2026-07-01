//
//  HeatmapPopupView.swift
//  todaktodot
//
//  Created by 임대진 on 7/1/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

final class HeatmapPopupView: UIView {
    private let titleLabel = TDLabel().then {
        $0.text = "우리의 활동"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale700
    }
    
    private let exitButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .grayScale800
    }
    
    private let grayBox = UIView().then {
        $0.backgroundColor = .grayScale50
        $0.layer.cornerRadius = 16
    }
    
    private let descriptionLabel = TDLabel().then {
        $0.text = "우리의 활동은 함께 쌓아온 대화의 기록입니다.\n대화가 쌓일수록 보라색 잔디가 더욱 풍성해집니다."
        $0.font = .pretenRegular(14)
        $0.textColor = .grayScale600
        $0.numberOfLines = 2
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 16
        
        setupFlexLayout()
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeColorBox(color: UIColor) -> UIView {
        return UIView().then {
            $0.backgroundColor = color
            $0.layer.cornerRadius = 1.6
        }
    }
    
    private func makeLabel(text: String) -> TDLabel {
        return TDLabel().then {
            $0.text = text
            $0.font = .pretenMedium(16)
            $0.textColor = .grayScale700
        }
    }
    
    private func setupFlexLayout() {
        self.flex
            .width(UIScreen.main.bounds.width - 40)
            .height(270)
            .marginHorizontal(20)
            .paddingHorizontal(20)
            .define {
                $0.addItem()
                    .direction(.row)
                    .height(32)
                    .marginTop(16)
                    .alignItems(.center)
                    .define {
                        $0.addItem(titleLabel)
                        $0.addItem()
                            .grow(1)
                        $0.addItem(exitButton)
                            .width(32)
                    }
                
                $0.addItem(grayBox)
                    .alignItems(.start)
                    .marginTop(8)
                    .paddingHorizontal(28)
                    .paddingVertical(20)
                    .gap(8)
                    .define {
                        $0.addItem()
                            .direction(.row)
                            .alignItems(.center)
                            .define {
                                $0.addItem(makeColorBox(color: .mainPurple))
                                    .size(20)
                                $0.addItem(makeLabel(text: "둘 다 답한 날"))
                                    .marginLeft(8)
                            }
                        $0.addItem()
                            .direction(.row)
                            .alignItems(.center)
                            .define {
                                $0.addItem(makeColorBox(color: .subPurple))
                                    .size(20)
                                $0.addItem(makeLabel(text: "한 명만 답한 날"))
                                    .marginLeft(8)
                            }
                        $0.addItem()
                            .direction(.row)
                            .alignItems(.center)
                            .define {
                                $0.addItem(makeColorBox(color: .grayScale100))
                                    .size(20)
                                $0.addItem(makeLabel(text: "아직 답하지 않은 날"))
                                    .marginLeft(8)
                            }
                    }
                
                $0.addItem(descriptionLabel)
                    .marginTop(12)
                    .marginBottom(32)
            }
    }
    
    @objc func didTapExitButton() {
        removeFromSuperview()
    }
}

