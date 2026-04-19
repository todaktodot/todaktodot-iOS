//
//  MaskingLabel.swift
//  todaktodot
//
//  Created by daye on 2/12/26.
//

import Foundation
import UIKit

/// 사용방법
/// let maskingText =  MaskingLabel(textColor: .grayScale900)
/// *주의 - 텍스트 컬러는 따로 정의하면 안되고 꼭 인자로 넘겨줘야함.. 방법이 있을것같은데 현재 귀찮

final class MaskingLabel: UILabel {

    private let tuning = TuningSet()
    let originalTextColor: UIColor
    
    private var originalText: String?
    private var isMasked = true
    private let bubbleContainer = UIView()
    private let touchLayer = UIView()
    private var bubbles: [CAShapeLayer] = []
    private var lastTouchPoint: CGPoint?
    private var bubbleTimer: Timer?
    private var cachedPositions: [CGPoint] = []
    private var lastLayoutSize: CGSize = .zero
    
    private let letterSpacing: CGFloat = 1
    
    override var text: String? {
        didSet {
            originalText = text

            if let text = text {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing =  1.26
                paragraphStyle.lineBreakMode = .byWordWrapping
                paragraphStyle.lineBreakStrategy = .hangulWordPriority
                
                let color = isMasked ? UIColor.clear : originalTextColor
                let attributedText = NSAttributedString(
                    string: text,
                    attributes: [
                        .font: font ?? UIFont.systemFont(ofSize: 17),
                        .paragraphStyle: paragraphStyle,
                        .foregroundColor: color,
                        .kern: letterSpacing
                    ]
                )
                super.attributedText = attributedText
            } else {
                super.text = nil
            }
            
            if isMasked {
                showBubbles()
            }
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            originalText = attributedText?.string
            lineBreakMode = .byWordWrapping

        }
    }
    
    required init?(coder: NSCoder) {
        self.originalTextColor = .grayScale900
        super.init(coder: coder)
        setup()
    }
    
    init(frame: CGRect = .zero, textColor: UIColor) {
        self.originalTextColor = textColor
        super.init(frame: frame)
        setup()
    }
    
    deinit {
        bubbleTimer?.invalidate()
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        clipsToBounds = false
        textColor = .clear
        
        bubbleContainer.backgroundColor = .clear
        bubbleContainer.isUserInteractionEnabled = false
        addSubview(bubbleContainer)
        
        touchLayer.backgroundColor = .clear
        touchLayer.isUserInteractionEnabled = true
        addSubview(touchLayer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        touchLayer.addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleContainer.frame = bounds
        touchLayer.frame = bounds
        
        if isMasked && originalText != nil && bounds.size != lastLayoutSize {
            lastLayoutSize = bounds.size
            bubbles.forEach { $0.removeFromSuperlayer() }
            bubbles.removeAll()
            
            recalculateBubblePositions()
        }
    }
    
    private func recalculateBubblePositions() {
        guard let originalText = originalText else { return }
        
        let attrString: NSMutableAttributedString
        if let existing = self.attributedText, existing.length > 0 {
            attrString = NSMutableAttributedString(attributedString: existing)
        } else {
            attrString = NSMutableAttributedString(string: originalText, attributes: [.font: font ?? UIFont.systemFont(ofSize: 17), .kern: letterSpacing])
        }
      
        let fullRange = NSRange(location: 0, length: attrString.length)
        let para = NSMutableParagraphStyle()
       
        para.lineBreakMode = .byWordWrapping
        para.lineBreakStrategy = .hangulWordPriority
        para.lineSpacing = 4.0 // 버블 스페이싱 조절. 텍스트랑 다르고 눈대중이라 테스트 더 해봐야함
        attrString.addAttribute(.paragraphStyle, value: para, range: fullRange)
        
        let textStorage = NSTextStorage(attributedString: attrString)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.ensureLayout(for: textContainer)
        
        // 각 글자의 중심 위치 저장
        var positions: [CGPoint] = []
        for i in 0..<originalText.count {
            let character = originalText[originalText.index(originalText.startIndex, offsetBy: i)]
            
            // 공백, 줄바꿈, 탭 제외
            if character.isWhitespace || character.isNewline {
                continue
            }
            
            let glyphIndex = layoutManager.glyphIndexForCharacter(at: i)
            guard glyphIndex < layoutManager.numberOfGlyphs else { continue }
            
            let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)
            positions.append(CGPoint(x: glyphRect.midX, y: glyphRect.midY))
        }
        
        startBubbleGeneration(at: positions, characterCount: positions.count)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard isMasked else { return }
        
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.prepare()
        haptic.impactOccurred()
        
        lastTouchPoint = gesture.location(in: self)
        isMasked = false
        bubbleTimer?.invalidate()
        bubbleTimer = nil
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.explodeBubbles()
            
            if let currentText = self.attributedText {
                let mutableAttr = NSMutableAttributedString(attributedString: currentText)
                mutableAttr.addAttribute(.foregroundColor, value: self.originalTextColor, range: NSRange(location: 0, length: mutableAttr.length))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + self.tuning.bubbleExplosionDuration * 0.3) {
                    UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve) {
                        self.attributedText = mutableAttr
                    }
                }
            }
        }
    }
    
    private func showBubbles() {
        bubbleContainer.isHidden = false
    }
    
    private func startBubbleGeneration(at positions: [CGPoint], characterCount: Int) {
        guard isMasked, characterCount > 0 else { return }
        
        bubbleTimer?.invalidate()
        cachedPositions = positions
        
        let interval = tuning.bubbleBatchInterval
        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            self?.generateBubbleBatch()
        }
        RunLoop.main.add(timer, forMode: .common)
        bubbleTimer = timer
        
        generateBubbleBatch()
    }
    
    private func generateBubbleBatch() {
        guard isMasked, !cachedPositions.isEmpty else {
            bubbleTimer?.invalidate()
            return
        }
        
        // 이미 제거된 버블 참조 일괄 정리
        bubbles.removeAll { $0.superlayer == nil }
        
        let bubblesCount = Int(Double(cachedPositions.count) * tuning.bubblesPerCharacter)
        
        for _ in 0..<bubblesCount {
            let randomPosition = cachedPositions.randomElement() ?? .zero
            let offsetX = CGFloat.random(in: -tuning.bubbleStartOffsetXRange...tuning.bubbleStartOffsetXRange)
            let offsetY = CGFloat.random(in: -tuning.bubbleStartOffsetYRange...tuning.bubbleStartOffsetYRange)
            let position = CGPoint(x: randomPosition.x + offsetX, y: randomPosition.y + offsetY)
            
            let bubble = createBubble(at: position)
            bubbleContainer.layer.addSublayer(bubble)
            bubbles.append(bubble)
            animateBubble(bubble)
        }
    }
    


}

// MARK: - Start
extension MaskingLabel {
    private func createBubble(at position: CGPoint) -> CAShapeLayer {
        let size = CGFloat.random(in: 1...2)
        
        let bubble = CAShapeLayer()
        bubble.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size)).cgPath
        bubble.fillColor = originalTextColor.withAlphaComponent(0.6).cgColor
        bubble.position = position
        
        return bubble
    }
}


// MARK: - During
extension MaskingLabel {
    private func animateBubble(_ bubble: CAShapeLayer) {
        let startPosition = bubble.position
        let duration = Double.random(in: tuning.bubbleAnimateMinDuration...tuning.bubbleAnimateMaxDuration)
        
        let randomAngle = CGFloat.random(in: 0...(2 * .pi))
        let randomDistance = CGFloat.random(in: tuning.minBubbleDistance...tuning.maxBubbleDistance)
        
        let newX = startPosition.x + cos(randomAngle) * randomDistance
        let newY = startPosition.y + sin(randomAngle) * randomDistance
        
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.toValue = CGPoint(x: newX, y: newY)
        moveAnimation.duration = duration
        moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = tuning.bubbleStartSize
        scaleAnimation.toValue = tuning.bubbleEndSize
        scaleAnimation.duration = duration
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        let group = CAAnimationGroup()
        group.animations = [moveAnimation, scaleAnimation]
        group.duration = duration
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak bubble] in
            bubble?.removeFromSuperlayer()
        }
        bubble.add(group, forKey: "bubbleAnimation")
        CATransaction.commit()
    }
}

// MARK: - End
extension MaskingLabel {
    private func hideBubbles() {
        bubbles.forEach { $0.removeAllAnimations(); $0.removeFromSuperlayer() }
        bubbles.removeAll()
        bubbleContainer.isHidden = true
    }
    
    // 버블 터치시 주변 버블 파동 애니메이션
    private func explodeBubbles() {
        guard let touchPoint = lastTouchPoint else {
            hideBubbles()
            return
        }
        
        for bubble in bubbles {
            let bubblePosition = bubble.position
            let dx = bubblePosition.x - touchPoint.x
            let dy = bubblePosition.y - touchPoint.y
            let distance = sqrt(dx * dx + dy * dy)
            
            let speed: CGFloat = tuning.bubbleExplosionDistance
            let duration = tuning.bubbleExplosionDuration
            let targetX = bubblePosition.x + (dx / distance) * speed
            let targetY = bubblePosition.y + (dy / distance) * speed
            
            let moveAnimation = CABasicAnimation(keyPath: "position")
            moveAnimation.toValue = CGPoint(x: targetX, y: targetY)
            moveAnimation.duration = duration
            moveAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.toValue = 0.0
            fadeAnimation.duration = duration
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
            
            let group = CAAnimationGroup()
            group.animations = [moveAnimation, fadeAnimation]
            group.duration = duration
            group.fillMode = .forwards
            group.isRemovedOnCompletion = false
            
            bubble.add(group, forKey: "explode")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.bubbles.forEach { $0.removeFromSuperlayer() }
            self?.bubbles.removeAll()
            self?.bubbleContainer.isHidden = true
        }
    }
}

extension MaskingLabel {
    struct TuningSet {
        // Start
        let bubblesPerCharacter: Double = 1.0 /// 글자당 생성할 버블 개수
        let bubbleBatchInterval: TimeInterval = 0.08  /// 버블 생성 간격
        let bubbleStartOffsetXRange: CGFloat = 6 /// 한 글자 중심 랜덤 버블 생성 반경.
        let bubbleStartOffsetYRange: CGFloat = 4
        
        // During
        let bubbleAnimateMinDuration: Double = 1.0 /// 버블 직선 운동 최소 지속시간
        let bubbleAnimateMaxDuration: Double = 1.0 /// 버블 직선 운동 최대 지속시간
        let minBubbleDistance: CGFloat = 7 /// 버블 직선 운동 최소 거리
        let maxBubbleDistance: CGFloat = 12/// 버블 직선 운동 최대 거리
        let bubbleStartOpacity: Double = 1.0/// 버블 시작 투명도
        let bubbleEndOpacity: Double = 0.4 /// 버블 마지막 투명도
        let bubbleStartSize: Double = 1.3/// 버블 시작 크기
        let bubbleEndSize: Double = 0.3 /// 버블 마지막 크기
        
        // End
        let bubbleExplosionDistance: CGFloat = 20  /// 터치부근 버블 파동반경
        let bubbleExplosionDuration: Double = 0.8 /// 터치시 버블 파동 애니메이션 지속시간
    }
}
