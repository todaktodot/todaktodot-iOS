//
//  VoteTableCell.swift
//  SharedLibraries
//
//  Created by 임대진 on 8/11/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then
import RxSwift

final class VoteTableCell: UITableViewCell {

    var disposeBag = DisposeBag()
    var onTapOption: ((Int, Int, Bool) -> Void)?
    var onTapMore: ((Int) -> Void)?
    static let identifier = "VoteTableCell"
    
    private var heartCount = 0
    private var heartSelected = false
    private var optionViews: [VoteOptionView] = []
    private var voteId: Int?

    private let nicknameLabel = UILabel().then {
        $0.textColor = .grayScale400
        $0.font = .pretenSemiBold(12)
    }

    private let questionLabel = UILabel().then {
        $0.textColor = .grayScale900
        $0.font = .pretenSemiBold(16)
        $0.numberOfLines = 0
    }
    
    private let topicLabel = UILabel().then {
        $0.textColor = .grayScale600
        $0.font = .pretenMedium(13)
    }
    
    private let dotView = UIView().then {
        $0.backgroundColor = .grayScale300
        $0.layer.cornerRadius = 1
    }
    
    private let isMineLabel = UILabel().then {
        $0.text = "내 투표"
        $0.textColor = .mainPurple
        $0.font = .pretenMedium(13)
    }
    
    private let timeLabel = UILabel().then {
        $0.textColor = .grayScale400
        $0.font = .pretenRegular(13)
    }
    
    private let participantLabel = UILabel().then {
        $0.textColor = .grayScale400
        $0.font = .pretenRegular(13)
    }

    private let optionsContainer = UIView()
    
    private let divider = UIView().then {
        $0.backgroundColor = .grayScale100
    }
    
    private let moreButton = UIButton().then {
        $0.setImage(UIImage(resource: .ellipsis), for: .normal)
    }

    private let likeButton = ImageTextButton(
        horizonPadding: 0,
        verticalPadding: 0,
        textLabelWidth: 50,
        spacing: 2,
        imageSize: 20,
        imageFirst: true).then {
        $0.customText.font = .pretenRegular(13)
        $0.customText.textColor = .grayScale400
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        bindAction()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.flex.layout(mode: .adjustHeight)
        divider.pin.horizontally().top().height(1)
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        contentView.frame.size.width = targetSize.width
        contentView.flex.layout(mode: .adjustHeight)

        return CGSize(width: targetSize.width, height: contentView.frame.height)
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(divider)
        contentView.flex
            .direction(.column)
            .padding(20)
            .define { flex in

                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .height(24)
                    .define { header in

                        header.addItem(nicknameLabel)

                        header.addItem()
                            .grow(1)

                        header.addItem(moreButton)
                            .size(24)
                    }

                flex.addItem(questionLabel)
                    .marginTop(4)
                
                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .height(12)
                    .marginTop(12)
                    .define {
                        $0.addItem(topicLabel)
                        
                        $0.addItem(dotView)
                            .marginLeft(4)
                            .size(2)
                        $0.addItem(isMineLabel)
                            .marginLeft(4)

                        $0.addItem()
                            .grow(1)

                        $0.addItem(timeLabel)
                    }

                flex.addItem(optionsContainer)
                    .marginTop(24)

                flex.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .marginTop(16)
                    .define { bottom in

                        bottom.addItem(likeButton)
                            .height(20)
                        
                        bottom.addItem()
                            .grow(1)

                        bottom.addItem(participantLabel)
                    }
            }
    }
    
    private func bindAction() {
        moreButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self, let voteId else { return }
                onTapMore?(voteId)
            }
            .disposed(by: disposeBag)
    }
    
    func configure(info: VoteInfo, isFirst: Bool) {
        if isFirst {
            divider.removeFromSuperview()
        }
        if info.mine {
            dotView.removeFromSuperview()
            isMineLabel.removeFromSuperview()
        }
        
        setData(info: info)
        
        likeButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
        
        optionsContainer.subviews.forEach { $0.removeFromSuperview() }
        optionViews.removeAll()

        optionsContainer.flex
            .direction(.column)
            .gap(8)
            .define { flex in
                
                info.options.forEach { option in
                    let view = VoteOptionView()

                    view.configure(voteOption: option, hasVoted: info.hasVoted, isClosed: info.time == "마감")
                    
                    view.onTap = { [weak self] optionId, isSelected in
                        if let voteId = self?.voteId {
                            self?.selectOption(voteId: voteId, optionId: optionId, isSelected: isSelected)
                        }
                    }

                    self.optionViews.append(view)

                    flex.addItem(view)
                        .height(44)
                }
            }
    }
    
    private func setData(info: VoteInfo) {
        voteId = info.voteId
        nicknameLabel.text = info.nickname
        questionLabel.text = info.title
        topicLabel.text = info.categoryName
        timeLabel.text = info.time
        participantLabel.text = "\(info.participantCnt)명 참여"
        
        heartCount = info.likeCnt
        heartSelected = info.hasLiked
        updateHeart()
        
        nicknameLabel.flex.markDirty()
        questionLabel.flex.markDirty()
        topicLabel.flex.markDirty()
        timeLabel.flex.markDirty()
        participantLabel.flex.markDirty()
        contentView.flex.layout()
    }
    
    func updateOption(info: VoteInfo) {
        setData(info: info)
        
        optionViews.enumerated().forEach { index, optionView in
            guard index < info.options.count else { return }

            let option = info.options[index]

            let state: VoteOptionState

            if info.hasVoted {
                state = option.selected ? .selected : .unSelected
            } else {
                state = .normal
            }

            optionView.updateState(
                state,
                percent: option.voteRate ?? 0, count: option.voteCnt ?? 0
            )
        }
    }
    
    private func updateHeart() {
        likeButton.customImage.image = heartSelected ? UIImage(resource: .voteHeartClicked) : UIImage(resource: .voteHeartNomal)
        likeButton.customText.text = heartSelected ? "\(heartCount + 1)" : "\(heartCount)"
        likeButton.customText.textColor = heartSelected ? .redErrorColor : .grayScale400
    }
    
    @objc func didTapHeart() {
        heartSelected.toggle()
        updateHeart()
    }

    private func selectOption(voteId: Int, optionId: Int, isSelected: Bool) {
        onTapOption?(voteId, optionId, isSelected)
    }
}
