//
//  ReportModalViewController.swift
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

enum ReportType: String, CaseIterable {
    case ABUSE = "욕설/비하 발언"
    case OBSCENE = "음란물/선정적 내용"
    case SPAM = "스팸/도배"
    case ADVERTISEMENT = "광고/홍보"
    case PRIVACY = "개인정보 노출"
    case ILLEGAL = "불법 정보"
    case DISLIKE = "마음에 들지 않음"
    
    var apiValue: String {
        String(describing: self)
    }
}

final class ReportModalViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    weak var coordinator: VoteCoordinator?
    
    private var radioButtons: [RadioButton] = []
    private var selectedReason: ReportType?
    private var reportTryCount = 0
    
    private let voteId: Int
    private let dimView = UIView().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    }
    
    private let modalView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "신고 이유는 무엇인가요?"
        $0.font = .pretenSemiBold(20)
        $0.textColor = .grayScale900
    }

    private let descriptionLabel = TDLabel().then {
        $0.text = "회원님의 신고는 익명으로 처리되니 걱정 마세요"
        $0.font = .pretenRegular(14)
        $0.textColor = .grayScale600
    }
    
    private let cancleButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.setTitleColor(.grayScale600, for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grayScale200.cgColor
    }
    
    private let reportButton = UIButton().then {
        $0.setTitle("신고하기", for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .grayScale400
        $0.layer.cornerRadius = 6
        $0.isEnabled = false
    }
    
    init(voteId: Int) {
        self.voteId = voteId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func bind(reactor: VoteReactor) {
        reactor.state
            .compactMap { $0.reportingVoteId }
            .distinctUntilChanged()
            .subscribe { id in
                self.coordinator?.onHidden?(id)
                self.coordinator?.showModal(type: .complete)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isError }
            .subscribe { error in
                if error == .reportFailure {
                    if self.reportTryCount < 3 {
                        self.reportTryCount += 1
                        self.showToast(message: "신고 접수에 실패했어요", bottomOffset: 70)
                    } else {
                        self.showToast(message: "잠시 후 다시 시도해주세요", bottomOffset: 70)
                        self.coordinator?.dismissModal()
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func makeRadioButton(type: ReportType) -> RadioButton {
        let button = RadioButton(type: type)
        return button
    }
    
    private func setupViews() {
        view.addSubview(dimView)
        view.addSubview(modalView)
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(swipeModal(_:)))
        dimView.addGestureRecognizer(dismiss)
        modalView.addGestureRecognizer(swipe)
        cancleButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportVote), for: .touchUpInside)
    }
    
    private func setupFlexLayout() {
        
        modalView.flex.paddingHorizontal(24).define { flex in
            flex.addItem(titleLabel)
                .marginTop(28)
                .height(27)
            
            flex.addItem(descriptionLabel)
                .marginTop(8)
                .height(18)
            
            flex.addItem()
                .marginTop(24)
                .gap(4)
                .define { flex in
                    ReportType.allCases.forEach { type in
                        let button = makeRadioButton(type: type)
                        radioButtons.append(button)
                        button.addTarget(self, action: #selector(didTapRadioButton(_:)), for: .touchUpInside)
                        
                        flex.addItem(button)
                            .height(40)
                    }
                }
            
            flex.addItem()
                .marginTop(24)
                .gap(12)
                .direction(.row)
                .define {
                    $0.addItem(cancleButton)
                        .height(52)
                        .grow(1)
                    $0.addItem(reportButton)
                        .height(52)
                        .grow(1)
                }
        }
    }
    
    private func layoutViews() {
        dimView.pin
            .all()
        
        modalView.pin
            .horizontally()
            .bottom()
            .height(517)
        
        modalView.flex.layout()
    }
    
    
    @objc func dismissModal() {
        coordinator?.dismissModal()
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
    
    @objc func reportVote() {
        if let selectedReason {
            reactor?.action.onNext(.tapReport(voteId: voteId, reason: selectedReason))
        }
    }
    
    @objc private func didTapRadioButton(_ sender: RadioButton) {
        for button in radioButtons {
            button.isSelected = button.type == sender.type
        }
        reportButton.backgroundColor = .mainPurple
        reportButton.isEnabled = true
        selectedReason = sender.type
    }
}

private final class RadioButton: UIButton {
    let type: ReportType
    
    private let textLabel = UILabel().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale700
    }
    
    private let radio = UIImageView().then {
        $0.image = UIImage(resource: .voteRadioButtonNomal)
    }
    
    init(type: ReportType) {
        self.type = type
        self.textLabel.text = type.rawValue
        super.init(frame: .zero)
        
        self.flex
            .direction(.row)
            .gap(8)
            .alignItems(.center)
            .define {
                $0.addItem(radio)
                    .size(24)
                $0.addItem(textLabel)
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            updateStyle()
        }
    }
    
    func updateStyle() {
        radio.image = UIImage(resource: isSelected ? .voteRadioButtonSelected : .voteRadioButtonNomal)
    }
}
