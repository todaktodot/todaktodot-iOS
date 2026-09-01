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
    
    private var shouldScrollToTop = false
    private var isLoading: Bool = false
    private var isPaginating = false
    private var isFetchingNextPage: Bool = false
    private var topic: CardSubject?
    private var isClosed: Bool?
    private var isMine: Bool?
    private var sortLatest: Bool?
    private var cursor: String?
    private var size: Int?
    private var hasNext: Bool?
    private var voteList: [VoteInfo]?
    
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
        isLoading = false
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
    
    func bind(reactor: VoteReactor) {
        
        reactor.state
            .map { $0.voteList }
            .distinctUntilChanged()
            .map { [weak self] voteListResponse -> [VoteListItem] in
                guard let self = self else { return [] }
                
                let votes = voteListResponse?.data
                
                if votes == nil {
                    return (0..<10).map { _ in
                            .skeleton(VoteInfo.dummy)
                    }
                }
                
                if self.isPaginating {
                    self.voteList = (self.voteList ?? []) + (votes ?? [])
                } else {
                    self.voteList = votes
                }
                
                self.cursor = voteListResponse?.nextCursor
                self.hasNext = voteListResponse?.hasNext
                
                guard let voteList = self.voteList, !voteList.isEmpty else {

                    return [.empty]

                }
                
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
                    
                    cell.onTapMore = { [weak self] voteId in
                        self?.coordinator?.showModal(type: .menu)
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
                    self.isLoading = false
                    self.isFetchingNextPage = false
                    scrollToTop()
                }
                
                tableView.isScrollEnabled = !isLoading
                
                let listCount = reactor.currentState.voteList?.data?.count ?? 0
                
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
            
            self.topic = topic
            self.isClosed = isClosed
            self.isMine = isMine
            
            fetchVotes(cursor: nil)
        }
        
        fetchVotes(cursor: nil)
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
    
    private func fetchVotes(cursor: String?, scrollToTop: Bool = true, paginating: Bool = false) {
        shouldScrollToTop = scrollToTop
        isPaginating = paginating
        
        reactor?.action.onNext(.isLoading(true))
        reactor?.action.onNext(.fetchVotes(category: topic, isClosed: isClosed, isMine: isMine, sortLatest: sortLatest, cursor: cursor, size: size))
    }
    
    private func showCloseAlert() {
        showAlert(icon: UIImage(resource: .warning), title: "방금 마감된 투표예요", description: "결과만 확인할 수 있어요", primaryButtonTitle: "확인", primaryButtonAction: {
        })
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
        if reactor?.currentState.voteList?.data?.isEmpty == true {
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
