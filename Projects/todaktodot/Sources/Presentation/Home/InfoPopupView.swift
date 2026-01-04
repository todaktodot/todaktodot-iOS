//
//  InfoPopupView.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import UIKit
import FlexLayout
import PinLayout

final class InfoPopupView: UIView {
    
    private let popupContainer = UIView()
    private let closeButtonContainer = UIView()
    private let closeButton = UIButton()
    private let contentContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        popupContainer.backgroundColor = .white
        popupContainer.layer.cornerRadius = 20
        popupContainer.layer.shadowColor = UIColor.black.cgColor
        popupContainer.layer.shadowOpacity = 0.1
        popupContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        popupContainer.layer.shadowRadius = 8
        addSubview(popupContainer)
        
        closeButtonContainer.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        closeButtonContainer.addGestureRecognizer(tapGesture)
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .grayScale600
        closeButton.isUserInteractionEnabled = false
        
        popupContainer.addSubview(closeButtonContainer)
        closeButtonContainer.addSubview(closeButton)
        popupContainer.addSubview(contentContainer)
        
        setupContent()
        
        popupContainer.flex
            .width(332)
            .padding(24)
            .define { flex in
                flex.addItem(closeButtonContainer).position(.absolute).top(0).right(0).size(60).define { closeFlex in
                    closeFlex.addItem(closeButton).position(.absolute).top(20).right(20).size(24)
                }
                flex.addItem(contentContainer).marginTop(4)
                    .marginBottom(24)
            }
    }
    
    private func setupContent() {
        let section1Title = createTitleLabel(text: "대화 모드를 통해\n대화의 깊이를 선택하세요")
        let section1Item1 = createItemLabel(text: "🍰 디저트 가볍게 웃으며 현실 얘기 시작하기")
        let section1Item2 = createItemLabel(text: "☕ 커피 솔직하게 서로의 다름을 알아가기")
        let section1Item3 = createItemLabel(text: "🥃 위스키 진지하게 핵심 가치관 이야기하기")
        
        let section2Title = createTitleLabel(text: "카테고리별 깊은 대화를 나누세요")
        let section2Item1 = createItemLabel(text: "💑 연애관 관계와 결혼 관련 대화")
        let section2Item2 = createItemLabel(text: "💸 경제관 돈, 소비, 계획 등 현실 주제")
        let section2Item3 = createItemLabel(text: "🏡 생활관 라이프스타일과 일상 이야기")
        
        let section3Title = createTitleLabel(text: "유형을 선택하여\n서로의 생각을 확인해보세요")
        let section3Item1 = createItemLabel(text: "🎭 상황극 상황 속 선택으로 행동·가치관 확인")
        let section3Item2 = createItemLabel(text: "⚖️ 밸런스게임 trade off 선택으로 우선순위 확인")
        
        contentContainer.flex.define { flex in
            flex.addItem(section1Title)
            flex.addItem(section1Item1).marginTop(12)
            flex.addItem(section1Item2).marginTop(8)
            flex.addItem(section1Item3).marginTop(8)
            
            flex.addItem(section2Title).marginTop(24)
            flex.addItem(section2Item1).marginTop(12)
            flex.addItem(section2Item2).marginTop(8)
            flex.addItem(section2Item3).marginTop(8)
            
            flex.addItem(section3Title).marginTop(24)
            flex.addItem(section3Item1).marginTop(12)
            flex.addItem(section3Item2).marginTop(8)
        }
    }
    
    private func createTitleLabel(text: String) -> UILabel {
        let label = TDLabel()
        label.font = .pretenSemiBold(16)
        label.textColor = .grayScale900
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        label.attributedText = NSAttributedString(
            string: text,
            attributes: [.paragraphStyle: paragraphStyle]
        )
        
        return label
    }
    
    private func createItemLabel(text: String) -> UILabel {
        let label = TDLabel()
        label.text = text
        label.font = .pretenMedium(14)
        label.textColor = .grayScale800
        label.numberOfLines = 0
        return label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        popupContainer.flex.layout(mode: .adjustHeight)
    }
    
    @objc private func dismiss() {
        let currentY = popupContainer.frame.minY
        
        UIView.animate(withDuration: 0.2, animations: {
            self.popupContainer.alpha = 0
            self.popupContainer.pin.top(currentY - 20)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    func show(in view: UIView, alignedWith cardView: UIView) {
        frame = view.bounds
        view.addSubview(self)
        
        popupContainer.flex.layout(mode: .adjustHeight)
        
        let cardFrameInView = cardView.convert(cardView.bounds, to: view)
        let finalY = cardFrameInView.minY
        
        popupContainer.pin.top(finalY - 20).right(view.bounds.width - cardFrameInView.maxX)
        popupContainer.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.popupContainer.alpha = 1
            self.popupContainer.pin.top(finalY)
        }
    }
}
