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
    
    private enum CellState {
        case normal(Bool)
        case hidden
        case skeleton
    }
    
    static let identifier = "VoteTableCell"
    
    var disposeBag = DisposeBag()
    var onTapMore: ((VoteInfo) -> Void)?
    var onTapLike: ((Int, Bool) -> Void)?
    var onTapOption: ((Int, Int, Bool) -> Void)?
    
    private var voteId: Int?
    private var likeCount = 0
    private var isLike = false
    private var isBlind: Bool = false
    private var currentInfo: VoteInfo?
    private var optionViews: [VoteOptionView] = []

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
    
    // MARK: - Hidden
    private let hiddenContainer = UIView().then {
        $0.backgroundColor = .grayScale100
        $0.layer.cornerRadius = 12
    }
    
    private let hiddenMoreButton = UIImageView().then {
        $0.tintColor = .grayScale200
        $0.image = UIImage(resource: .ellipsis)
    }
    
    private func makeHiddenStick() -> UIView {
        let view = UIView().then {
            $0.backgroundColor = .grayScale200
            $0.layer.cornerRadius = 5
        }
        return view
    }
    
    private let hiddenLabel = UILabel().then {
        $0.text = "신고하여 숨김 처리된 게시물이예요"
        $0.textColor = .grayScale600
        $0.font = .pretenSemiBold(15)
    }
    
    // MARK: - MypageBlind
    private let blindContainer = UIView().then {
        $0.backgroundColor = .grayScale700.withAlphaComponent(0.85)
        $0.layer.cornerRadius = 8
    }
    
    private let blindIcon = UIImageView().then {
        $0.image = UIImage(resource: .warningGray)
    }
    
    private let blindLabel = UILabel().then {
        $0.text = "신고 누적으로 인해\n블라인드 처리 됐어요"
        $0.textColor = .white
        $0.font = .pretenBold(16)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    private let blindDescriptionLabel = UILabel().then {
        $0.text = "다른 유저의 피드에서는 더 이상 보이지 않아요"
        $0.textColor = .white
        $0.font = .pretenRegular(14)
        $0.textAlignment = .center
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
        setupHiddenUI()
        setupBlindUI()
        setupSkeletonUI()
        bindAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.flex.layout(mode: .adjustHeight)
        
        if isBlind {
            blindContainer.isHidden = false
            setupBlindLayout()
        } else {
            blindContainer.isHidden = true
        }
        if !skeletonContainer.isHidden {
            skeletonContainer.pin.all()
            skeletonContainer.flex.layout()
        }
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
    
    // MARK: - Config
    func configure(info: VoteInfo, isFirst: Bool, isHidden: Bool = false, isBlind: Bool = false) {
        self.isBlind = isBlind
        
        if isHidden {
            showHidden()
            return
        } else {
            hiddenContainer.isHidden = true
            hiddenContainer.flex.display(.none)
        }
        
        divider.isHidden = isFirst
        divider.flex.display(isFirst ? .none : .flex)
        dotView.isHidden = !info.isMine
        isMineLabel.isHidden = !info.isMine
        setData(info: info)
        
        optionsContainer.subviews.forEach { $0.removeFromSuperview() }
        optionViews.removeAll()
        
        optionsContainer.flex
            .direction(.column)
            .gap(8)
            .define { flex in
                info.options.forEach { option in
                    let view = VoteOptionView()
                    view.configure(
                        voteOption: option,
                        hasVoted: info.hasVoted,
                        isClosed: info.time == "마감",
                        isHighest: findHighestVoteId(info) != nil ? option.optionId == findHighestVoteId(info) : nil
                    )
                    
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
    }

    func updateOption(info: VoteInfo) {
        
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
                percent: option.voteRate ?? 0,
                count: option.voteCnt ?? 0,
                isConfig: false,
                isHighest: findHighestVoteId(info) != nil ? option.optionId == findHighestVoteId(info) : nil
            )
        }
        setData(info: info)
        setNeedsLayout()
        layoutIfNeeded()
    }

    
    func showHidden() {
        stopSkeletonAnimation()
        setState(.hidden)
    }

    func showSkeleton() {
        setState(.skeleton)
        startSkeletonAnimation()
    }

    func hideSkeleton(animate: Bool) {
        guard !skeletonContainer.isHidden else { return }

        stopSkeletonAnimation()
        setState(.normal(animate))
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.flex.define { flex in
            flex.addItem(divider).height(1)
            flex.addItem(voteContainer)
            flex.addItem(hiddenContainer)
                .margin(20)
                .display(.none)
        }
        
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
    
    private func setupHiddenUI() {
        hiddenContainer.flex
            .height(130)
            .padding(20)
            .define {
                $0.addItem()
                    .height(23)
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                        $0.addItem(makeHiddenStick())
                            .width(70)
                            .height(10)
                        
                        $0.addItem().grow(1)
                        
                        $0.addItem(hiddenMoreButton)
                    }
                
                $0.addItem(hiddenLabel)
                    .alignSelf(.center)
                    .marginTop(17)
                
                $0.addItem(makeHiddenStick())
                    .width(183)
                    .marginTop(14)
                    .height(10)
                
                $0.addItem()
                    .direction(.row)
                    .alignItems(.center)
                    .marginTop(5)
                    .define {
                        $0.addItem(makeHiddenStick())
                            .width(151)
                            .height(10)
                        
                        $0.addItem().grow(1)
                        
                        $0.addItem(makeHiddenStick())
                            .width(27)
                            .height(10)
                    }
            }
        
        hiddenContainer.flex.display(.none)
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
    
    private func setupBlindUI() {
        contentView.addSubview(blindContainer)
        blindContainer.addSubview(blindIcon)
        blindContainer.addSubview(blindLabel)
        blindContainer.addSubview(blindDescriptionLabel)
    }
    
    private func setupBlindLayout() {
        blindContainer.pin
            .top(48)
            .horizontally(20)
            .bottom(20)

        blindIcon.pin
            .hCenter()
            .vCenter(-50)
            .size(48)

        blindLabel.pin
            .hCenter()
            .below(of: blindIcon, aligned: .center)
            .marginTop(8)
            .width(255)
            .sizeToFit()

        blindDescriptionLabel.pin
            .hCenter()
            .below(of: blindLabel, aligned: .center)
            .marginTop(12)
            .width(255)
            .sizeToFit()
    }
    
    private func setState(_ state: CellState) {
        switch state {
        case .normal(let animate):
            isUserInteractionEnabled = true

            voteContainer.isHidden = false
            voteContainer.flex.display(.flex)

            hiddenContainer.isHidden = true
            hiddenContainer.flex.display(.none)

            skeletonContainer.isHidden = true
            skeletonContainer.flex.display(.none)

            if animate {
                voteContainer.alpha = 0.0
                voteContainer.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }

        case .hidden:
            isUserInteractionEnabled = false

            voteContainer.isHidden = true
            voteContainer.flex.display(.none)

            hiddenContainer.isHidden = false
            hiddenContainer.flex.display(.flex)

            skeletonContainer.isHidden = true
            skeletonContainer.flex.display(.none)

        case .skeleton:
            isUserInteractionEnabled = false

            voteContainer.isHidden = true
            voteContainer.flex.display(.none)

            hiddenContainer.isHidden = true
            hiddenContainer.flex.display(.none)

            skeletonContainer.isHidden = false
            skeletonContainer.flex.display(.flex)
        }
        
        contentView.flex.markDirty()
        
        switch state {
        case .normal(let animate):
            if animate {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                    self.voteContainer.alpha = 1.0
                    self.voteContainer.transform = .identity
                }
            }
        case .hidden, .skeleton:
            return
        }
    }
    
    
    private func setData(info: VoteInfo) {
        currentInfo = info
        voteId = info.voteId
        nicknameLabel.text = info.nickname
        questionLabel.text = info.title
        topicLabel.text = info.categoryName
        timeLabel.text = info.time
        participantLabel.text = info.isClosed && info.participantCnt == 0 ? "아무도 참여하지 않고 마감됐어요" : "\(info.participantCnt)명 참여"
        
        likeCount = info.likeCnt
        isLike = info.hasLiked
        setLike()
        
        nicknameLabel.flex.markDirty()
        questionLabel.flex.markDirty()
        topicLabel.flex.markDirty()
        timeLabel.flex.markDirty()
        participantLabel.flex.markDirty()
        contentView.flex.layout()
    }
    
    private func setLike() {
        likeButton.customImage.image = isLike ? UIImage(resource: .voteHeartClicked) : UIImage(resource: .voteHeartNomal)
        likeButton.customText.textColor = isLike ? .redErrorColor : .grayScale400
        likeButton.customText.text = "\(likeCount)"
    }
    
    private func bindAction() {
        likeButton.rx.tap
            .subscribe { [weak self] _ in
                self?.updateLike()
            }
            .disposed(by: disposeBag)

        moreButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self, let currentInfo else { return }
                onTapMore?(currentInfo)
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
    
    private func updateLike() {
        if isLike {
            likeCount -= 1
        } else {
            likeCount += 1
        }
        isLike.toggle()
        
        likeButton.customText.text = "\(likeCount)"
        likeButton.customImage.image = isLike ? UIImage(resource: .voteHeartClicked) : UIImage(resource: .voteHeartNomal)
        likeButton.customText.textColor = isLike ? .redErrorColor : .grayScale400
        
        if let voteId {
            onTapLike?(voteId, isLike)
        }
    }
    
    private func selectOption(voteId: Int, optionId: Int, isSelected: Bool) {
        onTapOption?(voteId, optionId, isSelected)
    }
    
    private func findHighestVoteId(_ info: VoteInfo) -> Int? {
        let maxVoteCount = info.options
            .map { $0.voteCnt ?? 0 }
            .max() ?? 0
        
        if maxVoteCount == 0 { return nil }

        let highestVoteIds = info.options
            .filter { ($0.voteCnt ?? 0) == maxVoteCount }
            .map(\.optionId)
        
        return highestVoteIds.count > 1 ? nil : highestVoteIds.first
    }
    
}
