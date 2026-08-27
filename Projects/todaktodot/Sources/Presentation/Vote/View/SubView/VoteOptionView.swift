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
    private var needsProgressLayout = true
    private var shouldAnimateProgress = false
    private var lastLaidOutSize = CGSize.zero
    var optionId: Int?
    private var percent: CGFloat?

    private let checkmarkView = UIImageView().then {
        $0.image = UIImage(resource: .checkmark)
    }
    private let trackView = UIView().then {
        $0.backgroundColor = .grayScale100
    }
    
    private let progressView = UIView().then {
        $0.backgroundColor = .subPurple
        $0.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
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
    
    private var state: VoteOptionState = .normal

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8
        trackView.layer.cornerRadius = 8
        progressView.layer.cornerRadius = 8

        insertSubview(trackView, at: 0)
        trackView.addSubview(progressView)


        flex
            .direction(.row)
            .alignItems(.center)
            .height(44)
            .paddingHorizontal(12)
            .paddingVertical(10)
            .define {
                
                $0.addItem(checkmarkView)
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

        guard needsProgressLayout || lastLaidOutSize != bounds.size else { return }

        setProgress()
        needsProgressLayout = false
        shouldAnimateProgress = false
        lastLaidOutSize = bounds.size
    }
    
    func configure(voteOption: VoteOption, hasVoted: Bool, isClosed: Bool) {
        self.optionId = voteOption.optionId
        self.percent = voteOption.voteRate
        
        titleLabel.text = voteOption.content
        
        if !isClosed {
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        }
        
        updateState(
            isClosed ? voteOption.selected ? .selected : .unSelected :
            hasVoted ? voteOption.selected ? .selected : .unSelected : .normal,
            percent: voteOption.voteRate ?? 0, count: voteOption.voteCnt ?? 0,
            isConfig: true
        )
        
        flex.markDirty()
        setNeedsLayout()
    }
    
    func updateState(
        _ state: VoteOptionState,
        percent: CGFloat,
        count: Int,
        isConfig: Bool = false
    ) {
        self.state = state
        self.percent = percent

        switch state {
        case .normal:
            checkmarkView.flex.display(.none)
            percentLabel.flex.display(.none)
            voteCountLabel.flex.display(.none)
            titleLabel.textColor = .grayScale800

        case .selected:
            checkmarkView.flex.display(.flex)
            percentLabel.flex.display(.flex)
            voteCountLabel.flex.display(.flex)

            percentLabel.text = "\(Int(percent))%"
            voteCountLabel.text = "\(Int(count))표"
            titleLabel.textColor = .grayScale800
            voteCountLabel.textColor = .grayScale800
            percentLabel.textColor = .grayScale800
            progressView.backgroundColor = .subPurple

        case .unSelected:
            checkmarkView.flex.display(.none)
            percentLabel.flex.display(.flex)
            voteCountLabel.flex.display(.flex)

            percentLabel.text = "\(Int(percent))%"
            voteCountLabel.text = "\(Int(count))표"
            titleLabel.textColor = .grayScale500
            voteCountLabel.textColor = .grayScale500
            percentLabel.textColor = .grayScale500
            progressView.backgroundColor = .grayScale200
        }

        percentLabel.flex.markDirty()
        voteCountLabel.flex.markDirty()
        flex.markDirty()
        flex.layout()

        if !isConfig {
            let targetWidth = bounds.width * (percent / 100)
            
            UIView.animate(
                withDuration: 1,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState]
            ) {
                self.progressView.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: targetWidth,
                    height: self.bounds.height
                )
            }
        }
    }

    private func setProgress() {
        let progress = min(max(percent ?? 0, 0), 100) / 100
        let progressWidth: CGFloat

        switch state {
        case .normal:
            progressWidth = 0

        case .selected, .unSelected:
            progressWidth = bounds.width * progress
        }

        let frame = CGRect(
            x: 0,
            y: 0,
            width: progressWidth,
            height: bounds.height
        )
        progressView.frame = frame
    }
    
    @objc private func didTap() {
        if let optionId {
            onTap?(optionId, state == .selected)
        }
    }
}
