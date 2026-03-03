//
//  AIReportViewController.swift
//  todaktodot
//
//  Created by 임대진 on 1/6/26.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa
import Then
import ReactorKit
import RxRelay

final class AIReportViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    weak var coordinator: AIReportCoordinator?
    private var creatable = true
    private var isInitial = false
    private var reportId: Int?
    private var currentSegment = BehaviorRelay<SeletedSegment>(value: .lastWeek)
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.contentInset.bottom = 100
    }
    
    private let backgroundView = UIImageView().then {
        $0.image = UIImage(resource: .aiReportBackground)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let segmentView = UIView()
    
    private let underLineView = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let selectedLineView = UIView().then {
        $0.backgroundColor = .grayScale900
    }
    
    private let rootContainer = UIView()
    private let lineContainer = UIView()
    private let contentView = UIView()
    private let emptyReportView = EmptyReportView()
    private let lastWeekAIReportView = LastWeekAIReportView()
    private let storageAIReportView = AIReportStorageView()
    
    private let lastWeekButton = UIButton().then {
        $0.setTitle("지난 한 주", for: .normal)
        $0.setTitleColor(.grayScale600, for: .normal)
        $0.setTitleColor(.grayScale900, for: .disabled)
        $0.titleLabel?.font = UIFont.pretenSemiBold(16)
        $0.isEnabled = false
    }
    
    private let storageButton = UIButton().then {
        $0.setTitle("돌아보기", for: .normal)
        $0.setTitleColor(.grayScale600, for: .normal)
        $0.setTitleColor(.grayScale900, for: .disabled)
        $0.titleLabel?.font = UIFont.pretenSemiBold(16)
    }
    
    enum SeletedSegment {
        case lastWeek, storage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupViews()
        setupFlexLayout()
        
        reactor?.action.onNext(.fetchReportIsCreated)
        reactor?.action.onNext(.fetchStorageListData)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    func bind(reactor: AIReportReactor) {
        
        reactor.state
            .compactMap { $0.reportCreated }
            .distinctUntilChanged { $0.reportId == $1.reportId }
            .subscribe { [weak self] created in
                guard let self else { return }
                creatable = created.creatable
                isInitial = created.initialize
                reportId = created.reportId
                switchSegment(segment: .lastWeek)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.reportData }
            .subscribe(onNext: { [weak self] detail, step in
                guard let self = self, let detail, let step else { return }
                switch step {
                case .first:
                    coordinator?.showDetail(step: isInitial ? .first : .full, detail: detail)
                    isInitial = false
                case .history:
                    coordinator?.showDetail(step: .history, detail: detail)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.storageData }
            .subscribe { [weak self] list in
                guard let self else { return }
                storageAIReportView.configure(listData: list)
            }
            .disposed(by: disposeBag)
        
        currentSegment
            .subscribe { [weak self] segment in
                guard let self else { return }
                switch segment {
                case .lastWeek:
                    switchSegment(segment: .lastWeek)
                case .storage:
                    switchSegment(segment: .storage)
                }
            }
            .disposed(by: disposeBag)
        
        lastWeekButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                currentSegment.accept(.lastWeek)
            }
            .disposed(by: disposeBag)

        storageButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                currentSegment.accept(.storage)
            }
            .disposed(by: disposeBag)
        
        lastWeekAIReportView.reportDetailButton.rx.tap
            .compactMap { [weak self] _ in
                guard let self = self,
                      let reportId = self.reportId else { return nil }
                return .tapReportDetailButton(reportId)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        storageAIReportView.onCardTap = { id in
            reactor.action.onNext(.tapStorageReport(id))
        }
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(rootContainer)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupFlexLayout() {
        rootContainer.flex.define {
            $0.addItem(segmentView)
                .marginHorizontal(20)
                .height(45)
            
            $0.addItem(lineContainer)
                .marginHorizontal(20)
                .height(2)
            
            $0.addItem(underLineView)
                .height(1)
        }
        
        segmentView.flex.direction(.row).define {
            $0.addItem().grow(1).direction(.row).justifyContent(.center).define {
                $0.addItem(lastWeekButton)
            }
            
            $0.addItem().grow(1).direction(.row).justifyContent(.center).define {
                $0.addItem(storageButton)
            }
        }
        
        lineContainer.flex.direction(.row).define {
            $0.addItem(selectedLineView)
                .left(0)
                .top(0)
                .height(2)
                .width(50%)
        }
        
        contentView.flex.define { flex in
            flex.addItem(emptyReportView).display(.none)
            flex.addItem(lastWeekAIReportView).display(.none)
            flex.addItem(storageAIReportView).display(.none)
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
        
        rootContainer.pin
            .top(view.pin.safeArea.top)
            .horizontally()
            .bottom()
        
        scrollView.pin
            .top(view.pin.safeArea.top + 48)
            .horizontally()
            .bottom()
        
        contentView.pin
            .top(20)
            .horizontally(20)
        
        rootContainer.flex.layout()
        contentView.flex.layout(mode: .adjustHeight)
        
        layoutSelectedLine(index: 0)
        
        scrollView.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height + 100)
    }
    
    private func layoutSelectedLine(index: Int) {
        let half = lineContainer.bounds.width / 2
        let x = index == 0 ? 0 : half

        let apply = {
            self.selectedLineView.frame.origin.x = x
        }
        UIView.animate(withDuration: 0.2, animations: apply)
    }
    
    private func switchSegment(segment: SeletedSegment) {
        lastWeekButton.isEnabled = segment == .storage
        storageButton.isEnabled = segment == .lastWeek
        
        emptyReportView.flex.display(segment == .storage ? .none : creatable ? .none : .flex)
        lastWeekAIReportView.flex.display(segment == .storage ? .none : creatable ? .flex : .none)
        storageAIReportView.flex.display(segment == .storage ? .flex : .none)
        contentView.flex.layout(mode: .adjustHeight)
        
        layoutSelectedLine(index: segment == .lastWeek ? 0 : 1)
    }
}

extension AIReportViewController: BaseViewControllerDelegate {
    func navigateToMyPage() {
        coordinator?.navigateToMyPage(self.navigationController, tabBarCoordinator: coordinator?.tabBarCoordinator)
    }
}
