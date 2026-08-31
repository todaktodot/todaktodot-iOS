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

    // MARK: - Skeleton
    private let skeletonContainer = UIView().then {
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    
    private let nicknameSkeleton = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let moreButtonSkeleton = UIImageView().then {
        $0.tintColor = .grayScale200
        $0.image = UIImage(resource: .ellipsis)
    }
    
    private let contentSkeleton1 = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let contentSkeleton2 = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let topicSkeleton = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let timeSkeleton = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let option1Skeleton = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let option2Skeleton = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let heartSkeleton = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let heartCountSkeleton = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let participantSkeleton = UIView().then {
        $0.backgroundColor = .grayScale200
    }

    // MARK: - UI
    private let voteContainer = UIView().then {
        $0.backgroundColor = .white
    }
    
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
        setupSkeletonUI()
        bindAction()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        disposeBag = DisposeBag()
//        
//        if let isLoading, isLoading {
//            skeletonContainer.isHidden = !isLoading
//            skeletonContainer.flex.display(isLoading ? .flex : .none)
//            voteContainer.isHidden = isLoading
//            voteContainer.flex.display(isLoading ? .none : .flex)
//            contentView.flex.markDirty()
//            setNeedsLayout()
//            layoutIfNeeded()
//        }
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.flex.layout(mode: .adjustHeight)
        
        if !skeletonContainer.isHidden {
            skeletonContainer.pin.all()
            skeletonContainer.flex.layout()
        } else {
            voteContainer.pin
                .top(1)
                .horizontally()
                .bottom()
            voteContainer.flex.layout()
        }
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
    
    func configure(info: VoteInfo, isFirst: Bool) {
        skeletonContainer.isHidden = true
        skeletonContainer.flex.display(.none)
        voteContainer.isHidden = false
        voteContainer.flex.display(.flex)
        
        if info.title.isEmpty {
            voteContainer.isHidden = true
        }
        divider.isHidden = isFirst
        dotView.isHidden = !info.isMine
        isMineLabel.isHidden = !info.isMine
        
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
        
        voteContainer.flex.markDirty()
        contentView.flex.markDirty()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func updateOption(info: VoteInfo) {
        setData(info: info)
        
        optionViews.enumerated().forEach { index, optionView in
            guard index < info.options.count else { return }
            let option = info.options[index]
            let state: VoteOptionState

            if info.hasVoted {
                state = option.isSelected ? .selected : .unSelected
            } else {
                state = .normal
            }

            optionView.updateState(
                state,
                percent: option.voteRate ?? 0, count: option.voteCnt ?? 0
            )
        }
    }
    
    func showSkeleton() {
        isUserInteractionEnabled = false
        
        voteContainer.isHidden = true
        voteContainer.flex.display(.none)
        
        skeletonContainer.isHidden = false
        skeletonContainer.flex.display(.flex)
        
        contentView.flex.markDirty()
        setNeedsLayout()
        layoutIfNeeded()
        startSkeletonAnimation()
    }

    func hideSkeleton() {
        guard !skeletonContainer.isHidden else { return }
        isUserInteractionEnabled = true
        stopSkeletonAnimation()
        
        skeletonContainer.isHidden = true
        skeletonContainer.flex.display(.none)
        
        voteContainer.isHidden = false
        voteContainer.flex.display(.flex)
        
        //TODO: 페이드인 효과
//        voteContainer.alpha = 0.0
//        voteContainer.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        
        contentView.flex.markDirty()
        setNeedsLayout()
        layoutIfNeeded()
        
//        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
//            self.voteContainer.alpha = 1.0
//            self.voteContainer.transform = .identity
//        }
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(divider)
        contentView.addSubview(voteContainer)
        voteContainer.flex
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
    
    private func setupSkeletonUI() {
        contentView.addSubview(skeletonContainer)
        
        skeletonContainer.flex
            .direction(.column)
            .padding(20)
            .define { flex in
                flex.addItem()
                    .direction(.row)
                    .alignItems(.end)
                    .define { flex in
                        flex.addItem(nicknameSkeleton)
                            .width(83)
                            .height(10.5)
                            .cornerRadius(5.25)
                        
                        flex.addItem().grow(1)
                        
                        flex.addItem(moreButtonSkeleton)
                            .width(20)
                    }
                flex.addItem(contentSkeleton1)
                    .width(229)
                    .height(14)
                    .cornerRadius(7)
                    .marginTop(12.5)
                
                flex.addItem(contentSkeleton2)
                    .width(296)
                    .height(14)
                    .cornerRadius(7)
                    .marginTop(6)
                
                flex.addItem()
                    .direction(.row)
                    .marginTop(22)
                    .define { flex in
                        flex.addItem(topicSkeleton)
                            .width(34)
                            .height(11.38)
                            .cornerRadius(5.69)
                        
                        flex.addItem().grow(1)
                        
                        flex.addItem(timeSkeleton)
                            .width(23)
                            .height(9)
                            .cornerRadius(4.5)
                    }
                
                flex.addItem(option1Skeleton)
                    .height(44)
                    .width(100%)
                    .marginTop(24)
                    .cornerRadius(8)
                
                flex.addItem(option2Skeleton)
                    .height(44)
                    .width(100%)
                    .marginTop(8)
                    .cornerRadius(8)
                
                flex.addItem()
                    .direction(.row)
                    .marginTop(19)
                    .alignItems(.center)
                    .define { flex in
                        flex.addItem(heartSkeleton)
                            .width(15)
                            .height(13.33)
                            .cornerRadius(6.66)
                        
                        flex.addItem(heartCountSkeleton)
                            .width(16)
                            .height(11.38)
                            .cornerRadius(5.69)
                            .marginLeft(4.5)
                        
                        flex.addItem().grow(1)
                        
                        flex.addItem(participantSkeleton)
                            .width(59)
                            .height(11.38)
                            .cornerRadius(5.69)
                    }
            }
        skeletonContainer.flex.display(.none)
    }

    private func bindAction() {
        moreButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self, let voteId else { return }
                onTapMore?(voteId)
            }
            .disposed(by: disposeBag)
    }
    
    private func startSkeletonAnimation() {
        skeletonContainer.alpha = 1.0
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            options: [.autoreverse, .repeat, .allowUserInteraction, .curveEaseInOut],
            animations: {
                self.skeletonContainer.alpha = 0.4
            },
            completion: nil
        )
    }
    
    private func stopSkeletonAnimation() {
        skeletonContainer.layer.removeAllAnimations()
        skeletonContainer.alpha = 1.0
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
