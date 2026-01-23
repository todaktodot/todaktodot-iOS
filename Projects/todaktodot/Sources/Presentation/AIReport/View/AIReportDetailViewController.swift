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
}

final class AIReportDetailViewController: UIViewController {
    var disposeBag = DisposeBag()
    weak var coordinator: AIReportCoordinator?
    private var dataEmpty = false
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
        $0.setTitle("다음", for: .normal)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "주간 AI 리포트"
        setupNavigationBar()
        setupViews()
        setupFlexLayout()
        bindActions()
        
        if step == .full {
            hiddenSubviesTitle()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentContainer)
    }
    
    private func setupNavigationBar() {
        
        let backButton = UIBarButtonItem(
            image: UIImage(resource: .back),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.titleTextAttributes = [
            .font: UIFont.pretenSemiBold(18),
            .foregroundColor: UIColor.grayScale900
        ]
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
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
            case .full:
                $0.addItem(firstDetailView)
                $0.addItem(secondDetailView)
                $0.addItem(thirdDetailView)
            }
            
            $0.addItem().grow(1)
            
            if step != .full {
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
    
    private func bindActions() {
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
    }
    
    private func hiddenSubviesTitle() {
        secondDetailView.hiddenTitleLabel()
        thirdDetailView.hiddenTitleLabel()
    }
    
    @objc private func backButtonTapped() {
        if step == .full {
            coordinator?.navigateRoot()
        } else {
            coordinator?.navigateBack()
        }
    }
}
