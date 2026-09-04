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
import Network

final class VoteViewController: BaseViewController, View {
    
    enum VoteListItem: Equatable {
        case vote(VoteInfo)
        case skeleton(VoteInfo)
        case empty
    }
    
    var disposeBag = DisposeBag()
    weak var coordinator: VoteCoordinator?
    
    private var shouldScrollToTop = false
    private var isLoading: Bool = false
    private var isPaginating = false
    private var isFetchingNextPage: Bool = false
    private var topic: [CardSubject]?
    private var isClosed: Bool?
    private var isMine: Bool?
    private var sortLatest: Bool?
    private var cursor: String?
    private var size: Int?
    private var hasNext: Bool?
    private var voteList: [VoteInfo]?
    private var hiddenVoteIds: [Int] = []
    private var isSetupNavigation = true
    private var isMypage: Bool
    private var filterCount = 0
    private var isEmptyVoteList = false
    private var todayVoteMakeCount = 0
    private var isSuspendedAccount = false
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitor")
    
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
        $0.register(
            VoteFilterEmptyCell.self,
            forCellReuseIdentifier: "VoteFilterEmptyCell"
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
    
    init(fromMypage: Bool = false) {
        self.isSetupNavigation = !fromMypage
        self.isMypage = fromMypage
        if fromMypage {
            voteHeaderView.filterButton.flex.display(.none)
        }
        
        super.init(nibName: nil, bundle: nil)
        isLoading = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    override var shouldSetupNavigation: Bool {
        isSetupNavigation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        setupViews()
        observeNetworkStatus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
        hideDefaultRefreshSpinner(in: refreshControl)
    }
    
    func bind(reactor: VoteReactor) {
        
        reactor.state
            .map { $0.voteList }
            .distinctUntilChanged()
            .map { [weak self] voteListResponse -> [VoteListItem] in
                guard let self = self else { return [] }
                let votes = voteListResponse?.data
                
                guard let voteListResponse else {
                    return (0..<10).map { _ in
                        .skeleton(VoteInfo.dummy)
                    }
                }
                
                if self.isPaginating {
                    self.voteList = (self.voteList ?? []) + (votes ?? [])
                } else {
                    self.voteList = votes
                }
                
                self.cursor = voteListResponse.nextCursor
                self.hasNext = voteListResponse.hasNext
                self.todayVoteMakeCount = voteListResponse.createVoteCnt ?? 0
                self.isSuspendedAccount = voteListResponse.isSuspended ?? false
                
                guard let voteList = self.voteList, !voteList.isEmpty else {
                    isEmptyVoteList = true
                    return [.empty]
                }
                
                isEmptyVoteList = false
                
                return voteList.map {
                    .vote($0)
                }
            }
            .bind(
                to: tableView.rx.items
            ) { [weak self] tableView, index, item in
                
                let indexPath = IndexPath(row: index, section: 0)
                
                switch item {
                case .empty:
                    if let count = self?.filterCount, count > 0 {
                        let cell = tableView.dequeueReusableCell(
                            withIdentifier: "VoteFilterEmptyCell",
                            for: indexPath
                        ) as! VoteFilterEmptyCell
                        
                        cell.selectionStyle = .none
                        
                        cell.onTapReset = { [weak self] in
                            self?.resetFilter()
                            self?.voteHeaderView.filterButton.updateFilter(count: 0)
                            self?.fetchVotes(cursor: nil)
                        }
                        
                        return cell
                    } else {
                        let cell = tableView.dequeueReusableCell(
                            withIdentifier: "VoteEmptyCell",
                            for: indexPath
                        ) as! VoteEmptyCell
                        
                        cell.selectionStyle = .none
                        
                        cell.onTapMake = { [weak self] in
                            self?.makeVote()
                        }
                        
                        return cell
                    }
                    
                case .vote(let info):
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "VoteTableCell",
                        for: indexPath
                    ) as! VoteTableCell
                    
                    cell.configure(
                        info: info,
                        isFirst: index == 0,
                        isHidden: self?.hiddenVoteIds.contains(info.voteId) ?? false,
                        isBlind: info.displayStatus == "HIDDEN"
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
                        self?.coordinator?.showModal(type: .menu(vote: info))
                    }
                    
                    cell.onTapLike = { [weak self] voteId, isLike in
                        guard let self,
                              self.reactor?.currentState.isLikeLoading == false
                        else {
                            return
                        }
                        reactor.action.onNext(.tapLike(voteId: voteId, isLike: isLike))
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
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] selectedVote in
                guard let self else { return }
                
                let voteList = self.voteList ?? []
                
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
                
                let wasPaginating = self.isFetchingNextPage
                
                if !isLoading {
                    refreshControl.endRefreshing()
                    lottie.alpha = 0
                    self.isLoading = false
                    self.isFetchingNextPage = false
                    scrollToTop()
                }
                
                tableView.isScrollEnabled = !isLoading
                
                tableView.visibleCells
                    .compactMap { $0 as? VoteTableCell }
                    .forEach { cell in
                        if isLoading {
                            cell.showSkeleton()
                        } else {
                            cell.hideSkeleton(animate: !wasPaginating)
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
                    showNetworkError()
                    
                case .voteFailure:
                    showToast(message: "잠시 후 다시 시도해주세요")
                    
                case .reportFailure:
                    return
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isClosedVoteId }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.showCloseAlert()
            })
            .disposed(by: disposeBag)
        
        makeVoteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                makeVote()
            })
            .disposed(by: disposeBag)
        
        voteHeaderView.filterButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                
                coordinator?.showModal(type: .filter, topic: topic, isClosed: isClosed, isMine: isMine)
            }
            .disposed(by: disposeBag)
        
        voteHeaderView.latestButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                
                sortLatest = true
                voteHeaderView.updateSort(isLatest: true)
                fetchVotes(cursor: nil)
            }
            .disposed(by: disposeBag)
        
        voteHeaderView.popularButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self else { return }
                
                sortLatest = false
                voteHeaderView.updateSort(isLatest: false)
                fetchVotes(cursor: nil)
            }
            .disposed(by: disposeBag)
        
        coordinator?.onFilter = { [weak self] topic, isClosed, isMine in
            guard let self else { return }
            var count = 0
            self.topic = topic
            self.isClosed = isClosed
            self.isMine = isMine
            
            if topic != nil { count += topic?.count ?? 0 }
            if isClosed != nil { count += 1 }
            if isMine == true { count += 1 }
            
            self.filterCount = count
            fetchVotes(cursor: nil)
            voteHeaderView.filterButton.updateFilter(count: count)
        }
        
        coordinator?.onHidden = { [weak self] voteId in
            guard let self else { return }
            let voteList = self.voteList ?? []
            
            guard let row = voteList.firstIndex(where: {
                $0.voteId == voteId
            }) else {
                return
            }
            
            let indexPath = IndexPath(row: row, section: 0)
            
            guard let cell = self.tableView.cellForRow(
                at: indexPath
            ) as? VoteTableCell else {
                return
            }
            
            hiddenVoteIds.append(voteId)
            cell.showHidden()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        fetchVotes(cursor: nil)
    }
    
    /// 투표 게시/수정 완료 후 리스트 새로고침 + 토스트
    func reloadAndToast(message: String) {
        resetFilter()
        fetchVotes(cursor: nil)
        showToast(message: message, bottomOffset: 70)
    }
    
    /// 투표 삭제 완료 후 프론트 즉시 제거 + 토스트
    func removeVoteAndToast(voteId: Int, message: String) {
        reactor?.action.onNext(.removeVoteLocally(voteId: voteId))
        showToast(message: message, bottomOffset: 70)
    }
    
    private func makeVote() {
        if isSuspendedAccount {
            showAlert(icon: UIImage(resource: .warning), title: "지금은 투표를 올릴 수 없어요", description: "신고 접수로 인해 작성이 정지되었어요", subDescription: "자세한 내용은 아래 메일로 문의해주세요\n✉️todaktodot26@gmail.com", primaryButtonTitle: "확인", primaryButtonAction: {})
        } else {
            if todayVoteMakeCount < 10 {
                coordinator?.showMakeVote()
            } else {
                showAlert(icon: UIImage(resource: .warning), title: "하루에 작성할 수 있는 투표를\n모두 채웠어요", description: "투표는 하루 최대 10개까지 올릴 수 있어요\n내일 새로운 질문으로 만나요!", primaryButtonTitle: "확인", primaryButtonAction: {})
            }
        }
    }
    
    private func fetchVotes(cursor: String?, scrollToTop: Bool = true, paginating: Bool = false) {
        shouldScrollToTop = scrollToTop
        isPaginating = paginating
        
        reactor?.action.onNext(.isLoading(true))
        if isMypage {
            reactor?.action.onNext(.fetchMyVoteList(sortLatest: sortLatest, cursor: cursor, size: size))
        } else {
            reactor?.action.onNext(.fetchVoteList(category: topic, isClosed: isClosed, isMine: isMine, sortLatest: sortLatest, cursor: cursor, size: size))
        }
    }
    
    private func resetFilter() {
        topic = nil
        isClosed = nil
        isMine = nil
        sortLatest = nil
        cursor = nil
        hiddenVoteIds = []
    }
    
    private func showCloseAlert() {
        showAlert(icon: UIImage(resource: .warning), title: "방금 마감된 투표예요", description: "결과만 확인할 수 있어요", primaryButtonTitle: "확인", primaryButtonAction: {
        })
    }
    
    private func scrollToTop(animated: Bool = true) {
        guard shouldScrollToTop else { return }
        
        tableView.scrollToRow(
            at: IndexPath(row: 0, section: 0),
            at: .top,
            animated: animated
        )
        shouldScrollToTop = false
    }
    
    private func setupViews() {
        
        tableView.delegate = self
        tableView.contentInset.bottom = isMypage ? 0 : 120
        refreshControl.tintColor = .clear
        hideDefaultRefreshSpinner(in: refreshControl)
        refreshControl.addSubview(lottie)
        refreshControl.bringSubviewToFront(lottie)
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        view.addSubview(errorView)
        
        if !isMypage {
            view.addSubview(makeVoteButton)
        }
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
        
        errorView.pin
            .width(248)
            .height(117)
            .center()
        
        view.flex.layout()
    }
    
    private func observeNetworkStatus() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self else { return }
                
                if path.status == .satisfied {
                    self.tableView.isHidden = false
                    self.errorView.isHidden = true
                    
                    if !self.isMypage {
                        self.makeVoteButton.isHidden = false
                    }
                } else {
                    self.showNetworkError()
                }
            }
        }
        
        networkMonitor.start(queue: networkQueue)
    }
    
    private func showNetworkError() {
        tableView.isHidden = true
        errorView.isHidden = false
        
        if !isMypage {
            makeVoteButton.isHidden = true
        }
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

        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.bounds.height
        let offsetY = scrollView.contentOffset.y

        guard contentHeight > 0 else { return }
        guard hasNext == true else { return }
        guard reactor?.currentState.isLoading == false && !isFetchingNextPage else { return }

        let threshold = contentHeight * 0.8

        if offsetY + visibleHeight >= threshold {
            isFetchingNextPage = true
            
            fetchVotes(
                cursor: cursor,
                scrollToTop: false,
                paginating: true
            )
        }
    }
    
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if scrollView.contentOffset.y <= -60 {
            if !isLoading {
                isLoading = true
                refreshControl.beginRefreshing()
                fetchVotes(cursor: nil)
            }
        } else {
            if isLoading {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.isLoading = false
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

        if isEmptyVoteList {
            return tableView.bounds.height - 200
        }

        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isEmptyVoteList && filterCount == 0 {
            return nil
        } else {
            return voteHeaderView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        54
    }
}
