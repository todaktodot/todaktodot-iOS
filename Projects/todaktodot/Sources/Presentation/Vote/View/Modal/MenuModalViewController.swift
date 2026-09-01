//
//  MenuModalViewController.swift
//  todaktodot
//
//  Created by 임대진 on 8/26/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout
import RxSwift
import RxRelay
import ReactorKit

final class MenuModalViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    weak var coordinator: VoteCoordinator?
    
    private var isMine: Bool { reactor?.currentState.isMine ?? false }
    private var hasParticipant: Bool { reactor?.currentState.hasParticipant ?? false }
    
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    private let modalView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    private let handleBarView = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let reportButton = UIButton().then {
        $0.setTitle("신고", for: .normal)
        $0.setTitleColor(.redErrorColor, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.contentHorizontalAlignment = .left
    }
    
    private let editButton = UIButton().then {
        $0.setTitle("수정", for: .normal)
        $0.setTitleColor(.grayScale900, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.contentHorizontalAlignment = .left
    }
    
    // 참여자가 있어 수정 불가일 때 표시
    private let editDisabledRow = UIView()
    private let editDisabledLabel = UILabel().then {
        $0.text = "수정 불가"
        $0.textColor = .grayScale400
        $0.font = .pretenSemiBold(16)
    }
    private let editDisabledHintLabel = UILabel().then {
        $0.text = "참여자가 1명 이상 존재해요"
        $0.textColor = .grayScale700
        $0.font = .pretenRegular(14)
        $0.textAlignment = .right
    }
    
    private let deleteButton = UIButton().then {
        $0.setTitle("삭제", for: .normal)
        $0.setTitleColor(.redErrorColor, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.contentHorizontalAlignment = .left
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupFlexLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    func bind(reactor: MenuModalReactor) {
        // Action
        editButton.rx.tap
            .map { MenuModalReactor.Action.tapEdit }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State - 수정 진입 허용 (최신 참여자 없음)
        reactor.state.compactMap { $0.editAllowedVote }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] latest in
                self?.coordinator?.dismissModal()
                self?.coordinator?.showEditVote(vote: latest)
            })
            .disposed(by: disposeBag)
        
        // State - 참여자가 생겨 수정 불가
        reactor.state.map { $0.isParticipantBlocked }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showAlert(
                    icon: UIImage(named: "Warning"),
                    title: "투표 참여자가 생기면 수정이 제한돼요",
                    description: "방금 참여자가 생겨 수정할 수 없어요\n이전 화면으로 돌아갈까요?",
                    primaryButtonTitle: "확인",
                    primaryButtonAction: { [weak self] in
                        self?.coordinator?.dismissModal()
                    }
                )
            })
            .disposed(by: disposeBag)
        
        // State - 삭제 완료
        reactor.state.map { $0.isDeleted }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let voteId = reactor.currentState.vote.voteId
                self?.coordinator?.didDeleteVote(voteId: voteId)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        view.addSubview(dimView)
        view.addSubview(modalView)
        
        reportButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(swipeModal(_:)))
        dimView.addGestureRecognizer(dismiss)
        modalView.addGestureRecognizer(swipe)
    }
    
    private func setupFlexLayout() {
        modalView.flex.paddingHorizontal(20).define {
            $0.addItem(handleBarView)
                .marginTop(12)
                .alignSelf(.center)
                .width(52)
                .height(6)
                .cornerRadius(3)
            
            if isMine {
                if hasParticipant {
                    // 참여자 있음 → 수정 불가 표시
                    editDisabledRow.flex.direction(.row).justifyContent(.spaceBetween).alignItems(.center).define {
                        $0.addItem(editDisabledLabel)
                        $0.addItem(editDisabledHintLabel)
                    }
                    $0.addItem(editDisabledRow)
                        .marginTop(20)
                        .height(40)
                        .width(view.bounds.width - 40)
                } else {
                    $0.addItem(editButton)
                        .marginTop(20)
                        .height(40)
                        .width(view.bounds.width - 40)
                }
                $0.addItem(deleteButton)
                    .marginTop(4)
                    .marginBottom(32)
                    .height(40)
                    .width(view.bounds.width - 40)
            } else {
                $0.addItem(reportButton)
                    .marginTop(20)
                    .marginBottom(32)
                    .height(40)
                    .width(view.bounds.width - 40)
            }
        }
    }
    
    private func layoutViews() {
        dimView.pin
            .all()
        
        modalView.pin
            .horizontally()
            .bottom()
            .height(isMine ? 160 : 110)
        
        modalView.flex.layout()
    }
    
    @objc func dismissModal() {
        coordinator?.dismissModal()
    }
    
    @objc private func didTapReport() {
        coordinator?.showModal(type: .report)
    }
    
    @objc private func didTapDelete() {
        guard let reactor else { return }
        let state = reactor.currentState
        let description = (state.hasParticipant || state.isClosed)
            ? "앗, 이미 투표가 시작되었어요!\n지금 삭제하면 소중한 투표 기록이\n모두 사라져요"
            : "한 번 삭제되면 복구할 수 없어요"
        
        showAlert(
            icon: UIImage(named: "Warning"),
            title: "투표를 삭제할까요?",
            description: description,
            primaryButtonTitle: "삭제",
            primaryButtonAction: { [weak self] in
                self?.reactor?.action.onNext(.confirmDelete)
            },
            secondaryButtonTitle: "취소",
            secondaryButtonAction: {}
        )
    }
    
    @objc func swipeModal(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        guard translation.y > 0 else { return }

        switch gesture.state {
        case .changed:
            modalView.transform = CGAffineTransform(
                translationX: 0,
                y: translation.y
            )

        case .ended:
            let velocity = gesture.velocity(in: view)

            if translation.y > 100 || velocity.y > 500 {
                coordinator?.dismissModal()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.modalView.transform = .identity
                }
            }

        default:
            break
        }
    }
}
