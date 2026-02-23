//
//  AIReportDetailViewController.swift
//  SharedLibraries
//
//  Created by 임대진 on 1/16/26.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa
import Then
import ReactorKit

enum AIReportViewStep {
    case first
    case second
    case third
    case full
    case history // TODO: 히스토리카드로 이동
}

final class AIReportDetailViewController: CustomBackViewController, View {
    var disposeBag = DisposeBag()
    weak var coordinator: AIReportCoordinator?
    private var dataEmpty = false
    private let aIReportLoadingView = AIReportLoadingView()
    private let firstDetailView = AIReportFirstView()
    private let secondDetailView = AIReportSecondView()
    private let thirdDetailView = AIReportThirdView()
    private let step: AIReportViewStep
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let backgroundView = UIImageView().then {
        $0.image = UIImage(resource: .aiReportBackground)
    }
    
    private let contentContainer = UIView()
    
    private let nextButton = UIButton().then {
        $0.setTitleColor(.mainPurple, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(16)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.mainPurple.cgColor
    }
    
    init(step: AIReportViewStep) {
        self.step = step
        super.init(nibName: nil, bundle: nil)
        nextButton.setTitle(step == .third ? "한 눈에 보기" : "다음", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        title = "주간 AI 리포트"
        setupViews()
        setupFlexLayout()
        
        if step == .full || step == .history {
            hiddenSubviesTitle()
        }
        if step == .first {
            showLoading()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    func bind(reactor: AIReportReactor) {
        nextButton.rx.tap
            .subscribe(onNext: { [weak self] in
                switch self?.step {
                case .first:
                    self?.coordinator?.showNext(step: .second)
                case .second:
                    self?.coordinator?.showNext(step: .third)
                case .third:
                    self?.coordinator?.showNext(step: .full)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        thirdDetailView.onTapTopic = {
            self.coordinator?.showNext(step: .history)
        }
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentContainer)
    }
    
    private func setupFlexLayout() {
        contentContainer.flex.marginHorizontal(20).minHeight(view.bounds.height - 130).define {
            switch step {
            case .first:
                $0.addItem(firstDetailView)
            case .second:
                $0.addItem(secondDetailView)
            case .third:
                $0.addItem(thirdDetailView)
            case .full, .history:
                $0.addItem(firstDetailView)
                $0.addItem(secondDetailView)
                $0.addItem(thirdDetailView)
            }
            
            $0.addItem().grow(1)
            
            if step != .full && step != .history {
                $0.addItem(nextButton)
                    .height(52)
                    .marginTop(40)
                    .marginBottom(14)
            }
        }
    }
    
    private func layoutViews() {
        let imgW: CGFloat = 375
        let imgH: CGFloat = 1743
        let screenW: CGFloat = UIScreen.main.bounds.width

        let scale = screenW / imgW
        let scaledHeight = imgH * scale
        
        backgroundView.pin
            .top()
            .horizontally()
            .height(scaledHeight)
        
        scrollView.pin
            .top(view.pin.safeArea.top)
            .horizontally()
            .bottom()
        
        contentContainer.pin
            .top()
            .horizontally()
        
        contentContainer.flex.layout(mode: .adjustHeight)
        
        scrollView.contentSize = contentContainer.frame.size
    }
    
    private func hiddenSubviesTitle() {
        secondDetailView.hiddenTitleLabel()
        thirdDetailView.hiddenTitleLabel()
    }
    
    private func showLoading() {
        view.addSubview(aIReportLoadingView)
        
        aIReportLoadingView.pin
            .all()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.aIReportLoadingView.isHidden = true
        }
    }
}

extension AIReportDetailViewController: CustomBackViewControllerDelegate {
    func navigateBack() {
        if step == .full {
            coordinator?.navigateRoot()
        } else {
            coordinator?.navigateBack()
        }
    }
}
