//
//  VoteOptionView.swift
//  todaktodot
//
//  Created by 임대진 on 8/11/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then

enum VoteOptionState: Codable, Equatable {
    case normal
    case selected
    case unSelected
}


final class VoteOptionView: UIView {

    var onTap: ((Int, Bool) -> Void)?
    var optionId: Int?
    
    private var percent: CGFloat = 0
    private var isClosedOption = false
    private var state: VoteOptionState = .normal

    private let checkmarkView = UIImageView().then {
        $0.image = UIImage(resource: .checkmark)
    }
    private let trackView = UIView().then {
        $0.backgroundColor = .grayScale100
    }
    
    private let progressView = UIView().then {
        $0.backgroundColor = .subPurple
        $0.frame = .zero
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .pretenSemiBold(14)
    }
    
    private let percentLabel = UILabel().then {
        $0.font = .pretenMedium(13)
        $0.text = ""
    }
    
    private let voteCountLabel = UILabel().then {
        $0.font = .pretenMedium(13)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8
        trackView.layer.cornerRadius = 8
        progressView.layer.cornerRadius = 8

        insertSubview(trackView, at: 0)
        trackView.addSubview(progressView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)

        flex
            .direction(.row)
            .alignItems(.center)
            .height(44)
            .paddingHorizontal(12)
            .paddingVertical(10)
            .define {
                $0.addItem(checkmarkView).marginRight(4)
                $0.addItem(titleLabel)
                $0.addItem().grow(1)
                $0.addItem(percentLabel)
                    .marginRight(4)
                $0.addItem(voteCountLabel)
            }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        trackView.pin.all()
        updateProgressFrame(animated: false)
    }
    
    func configure(voteOption: VoteOption, hasVoted: Bool, isClosed: Bool, isHighest: Bool?) {
        self.optionId = voteOption.optionId
        self.isClosedOption = isClosed
        self.titleLabel.text = voteOption.content
        
        let targetState: VoteOptionState
        if hasVoted {
            targetState = voteOption.isSelected ? .selected : .unSelected
        } else {
            targetState = .normal
        }
        
        updateState(
            targetState,
            percent: voteOption.voteRate ?? 0,
            count: voteOption.voteCnt ?? 0,
            isConfig: true,
            isHighest: isHighest
        )
    }
    
    func updateState(
        _ state: VoteOptionState,
        percent: CGFloat,
        count: Int,
        isConfig: Bool = false,
        isHighest: Bool?,
    ) {
        self.state = state
        self.percent = percent
        
        percentLabel.text = "\(Int(percent))%"
        voteCountLabel.text = "\(Int(count))표"

        switch state {
        case .normal:
            checkmarkView.flex.display(.none)
            percentLabel.flex.display(.none)
            voteCountLabel.flex.display(.none)

        case .selected:
            checkmarkView.image = UIImage(resource: isHighest == true ? .checkmark : .checkmarkGray)
            
            checkmarkView.flex.display(.flex)
            percentLabel.flex.display(.flex)
            voteCountLabel.flex.display(.flex)

        case .unSelected:
            checkmarkView.flex.display(.none)
            percentLabel.flex.display(.flex)
            voteCountLabel.flex.display(.flex)
        }
        
       if let isHighest {
            progressView.backgroundColor = isHighest ? .subPurple : .grayScale200
            titleLabel.textColor = isHighest ? .grayScale800 : .grayScale500
            voteCountLabel.textColor = isHighest ? .grayScale800 : .grayScale500
            percentLabel.textColor = isHighest ? .grayScale800 : .grayScale500
        } else {
            progressView.backgroundColor = .grayScale200
            
            switch state {
            case .normal:
                titleLabel.textColor = .grayScale800
                voteCountLabel.textColor = .grayScale800
                percentLabel.textColor = .grayScale800

            case .unSelected, .selected:
                titleLabel.textColor = .grayScale500
                voteCountLabel.textColor = .grayScale500
                percentLabel.textColor = .grayScale500
            }
        }
        
        percentLabel.flex.markDirty()
        voteCountLabel.flex.markDirty()
        flex.markDirty()
        flex.layout()

        progressView.layer.removeAllAnimations()

        if isConfig {
            setNeedsLayout()
        } else {
            updateProgressFrame(animated: true)
        }
    }

    private func updateProgressFrame(animated: Bool) {
        guard bounds.width > 0 else { return }

        let targetWidth: CGFloat
        if state == .normal {
            targetWidth = 0
        } else {
            targetWidth = bounds.width * (min(max(percent, 0), 100) / 100)
        }

        let targetFrame = CGRect(x: 0, y: 0, width: targetWidth, height: bounds.height)

        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState]
            ) {
                self.progressView.frame = targetFrame
            }
        } else {
            progressView.frame = targetFrame
        }
    }
    
    @objc private func didTap() {
        guard !isClosedOption, let optionId else { return }
        onTap?(optionId, state == .selected)
    }
}
