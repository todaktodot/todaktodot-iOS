//
//  VoteViewController.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa
import Then
import ReactorKit
import RxRelay
import Lottie

final class VoteViewController: BaseViewController, View {
    
    enum VoteListItem: Equatable {
        case vote(VoteInfo)
        case skeleton(VoteInfo)
        case empty
    }
    
    var disposeBag = DisposeBag()
    weak var coordinator: VoteCoordinator?
    
    private var isRefreshing: Bool = false
    private var category: CardSubject?
    private var status: Bool?
    private var isMine: Bool?
    private var SortLatest: Bool?
    private var cursor: Int?
    private var size: Int?
    
    private let tableView = UITableView().then {
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 270
        $0.separatorStyle = .none
        $0.sectionHeaderTopPadding = 0
        $0.register(
            VoteTableCell.self,
            forCellReuseIdentifier: "VoteTableCell"
        )
        $0.register(
            VoteEmptyCell.self,
            forCellReuseIdentifier: "VoteEmptyCell"
        )
    }
    
    private let errorView = VoteErrorView().then {
        $0.isHidden = true
    }
    
    private let lottie = LottieAnimationView(name: "voteLoadingSpinner").then {
        $0.loopMode = .loop
        $0.contentMode = .scaleAspectFit
        $0.play()
        $0.alpha = 0
    }
    
    private let makeVoteButton = MakeVoteButton()
    private let voteHeaderView = VoteHeaderView()
    private let refreshControl = UIRefreshControl()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        isRefreshing = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        
        tableView.delegate = self
        refreshControl.tintColor = .clear
        hideDefaultRefreshSpinner(in: refreshControl)
        refreshControl.addSubview(lottie)
        refreshControl.bringSubviewToFront(lottie)
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        view.addSubview(makeVoteButton)
    }
    
    private func hideDefaultRefreshSpinner(in view: UIView) {
        for subview in view.subviews {
            if let spinner = subview as? UIActivityIndicatorView {
                spinner.alpha = 0
                spinner.isHidden = true
            } else {
                hideDefaultRefreshSpinner(in: subview)
            }
        }
    }
    private func layoutViews() {
        
        tableView.pin
            .top(view.pin.safeArea.top)
            .horizontally()
            .bottom()
        
        makeVoteButton.pin
            .bottom(112)
            .right(20)
        
        lottie.pin
            .width(150)
            .height(75)
            .center()
        
        view.flex.layout()
    }
    
    private func refresh() {
        reactor?.action.onNext(.isLoading(true))
        reactor?.action.onNext(.fetchVotes(category: nil, status: true, isMine: false, sortLatest: true, cursor: nil, size: 10))
    }
    
    /// 투표 게시/수정 완료 후 리스트 새로고침 + 토스트
    func reloadAndToast(message: String) {
        refresh()
        showToast(message: message, bottomOffset: 70)
    }
    
    /// 투표 삭제 완료 후 프론트 즉시 제거 + 토스트
    func removeVoteAndToast(voteId: Int, message: String) {
        reactor?.action.onNext(.removeVoteLocally(voteId: voteId))
        showToast(message: message, bottomOffset: 70)
    }
    
    private func showCloseAlert() {
        showAlert(icon: UIImage(resource: .warning), title: "방금 마감된 투표예요", description: "결과만 확인할 수 있어요", primaryButtonTitle: "확인", primaryButtonAction: {
        })
    }
    func bind(reactor: VoteReactor) {
        
        reactor.state
            .map { state -> [VoteListItem] in
                if state.voteList == nil {
                    return (0..<10).map { _ in
                            .skeleton(VoteInfo.dummy)
                    }
                }
                
                let votes = state.voteList?.data ?? []
                
                if votes.isEmpty {
                    return [.empty]
                }
                
                return votes.map {
                    .vote($0)
                }
            }
            .distinctUntilChanged()
            .bind(
                to: tableView.rx.items
            ) { [weak self] tableView, index, item in
                
                let indexPath = IndexPath(row: index, section: 0)
                
                switch item {
                case .empty:
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "VoteEmptyCell",
                        for: indexPath
                    ) as! VoteEmptyCell
                    
                    return cell
                    
                case .vote(let info):
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "VoteTableCell",
                        for: indexPath
                    ) as! VoteTableCell
                    
                    cell.configure(
                        info: info,
                        isFirst: index == 0
                    )
                    
                    cell.onTapOption = { [weak self] voteId, optionId, isSelected in
                        self?.reactor?.action.onNext(
                            .tapOption(
                                voteId: voteId,
                                optionId: optionId,
                                isWithdrawal: isSelected
                            )
                        )
                    }
                    
                    cell.onTapMore = { [weak self] info in
                        guard let self else { return }
                        
                        self.coordinator?.showModal(type: .menu(vote: info))
                    }
                    
                    return cell
                    
                case .skeleton(let info):
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "VoteTableCell",
                        for: indexPath
                    ) as! VoteTableCell
                    
                    cell.configure(
                        info: info,
                        isFirst: index == 0
                    )
                    cell.showSkeleton()
                    
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.selectedVote }
            .subscribe(onNext: { [weak self] selectedVote in
                guard let self else { return }
                
                let voteList = self.reactor?.currentState.voteList?.data ?? []
                
                guard let row = voteList.firstIndex(where: {
                    $0.voteId == selectedVote.voteId
                }) else {
                    return
                }
                
                let indexPath = IndexPath(row: row, section: 0)
                
                guard let cell = self.tableView.cellForRow(
                    at: indexPath
                ) as? VoteTableCell else {
                    return
                }
                
                cell.updateOption(
                    info: selectedVote
                )
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isLoading }
            .subscribe(onNext: { [weak self] isLoading in
                guard let self else { return }
                
                if !isLoading {
                    refreshControl.endRefreshing()
                    lottie.alpha = 0
                    isRefreshing = false
                }
                
                tableView.isScrollEnabled = !isLoading
                
                let listCount = reactor.currentState.voteList?.data.count ?? 0
                
                for i in 0..<listCount {
                    let indexPath = IndexPath(row: i, section: 0)
                    guard let cell = tableView.cellForRow(
                        at: indexPath
                    ) as? VoteTableCell else {
                        return
                    }
                    if isLoading {
                        cell.showSkeleton()
                    } else {
                        cell.hideSkeleton()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isError }
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                
                switch error {
                case .empty:
                    return
                case .network:
                    tableView.isHidden = true
                    errorView.isHidden = false
                    
                    view.addSubview(errorView)
                    errorView.pin
                        .width(248)
                        .height(117)
                        .center()
                    
                case .voteFailure:
                    showToast(message: "잠시 후 다시 시도해주세요")
                }
                
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isClosedVote }
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.showCloseAlert()
            })
            .disposed(by: disposeBag)
        
        makeVoteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                coordinator?.showMakeVote()
            })
            .disposed(by: disposeBag)
        
        voteHeaderView.filterButton.rx.tap
            .subscribe { [weak self] _ in
                self?.coordinator?.showModal(type: .filter)
            }
            .disposed(by: disposeBag)
        
        voteHeaderView.latestButton.rx.tap
            .subscribe { [weak self] _ in
                self?.voteHeaderView.updateSort(isLatest: true)
            }
            .disposed(by: disposeBag)
        
        voteHeaderView.popularButton.rx.tap
            .subscribe { [weak self] _ in
                self?.voteHeaderView.updateSort(isLatest: false)
            }
            .disposed(by: disposeBag)
        
        reactor.action.onNext(.isLoading(true))
        reactor.action.onNext(.fetchVotes(category: nil, status: true, isMine: false, sortLatest: true, cursor: nil, size: 10))
    }
}

extension VoteViewController: BaseViewControllerDelegate {
    func navigateToMyPage() {
        coordinator?.navigateToMyPage(self.navigationController, tabBarCoordinator: coordinator?.tabBarCoordinator)
    }
}

extension VoteViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        makeVoteButton.isScrolled = scrollView.contentOffset.y > 0
        
        let pullDistance = min(max(-scrollView.contentOffset.y, 1), 60)
        let progress = pullDistance / 60
        lottie.alpha = progress
    }
    
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if scrollView.contentOffset.y <= -60 {
            if !isRefreshing {
                isRefreshing = true
                refreshControl.beginRefreshing()
                refresh()
            }
        } else {
            if isRefreshing {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.isRefreshing = false
                    self.tableView.setContentOffset(
                        CGPoint(
                            x: 0,
                            y: -self.tableView.adjustedContentInset.top
                        ),
                        animated: true
                    )
                }
            }
        }
    }
}

extension VoteViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        if reactor?.currentState.voteList?.data.isEmpty == true {
            return tableView.bounds.height - (54 + 72)
        }
        
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        voteHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        54
    }
}
