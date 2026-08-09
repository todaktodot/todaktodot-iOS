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

final class VoteViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    weak var coordinator: VoteCoordinator?
    
    private let makeVoteButton = MakeVoteButton()
    private let scrollView = UIScrollView()
    private let contentView = UIView().then {
        $0.backgroundColor = .grayScale300
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        setupViews()
        setupFlexLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    func bind(reactor: VoteReactor) {
        makeVoteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                coordinator?.showMakeVote()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        scrollView.delegate = self

        view.addSubview(scrollView)
        view.addSubview(makeVoteButton)
        scrollView.addSubview(contentView)
    }
    
    private func setupFlexLayout() {

        contentView.frame.size = CGSize(
            width: view.bounds.width,
            height: 1000
        )
        
        scrollView.contentSize = contentView.frame.size
    }
    
    private func layoutViews() {
        
        scrollView.pin.all()
        
        makeVoteButton.pin
            .bottom(112)
            .right(20)
        
        view.flex.layout()
    }
}

extension VoteViewController: UIScrollViewDelegate {
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        makeVoteButton.isScrolled = true
//    }
//    
//    func scrollViewDidEndDragging( _ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            makeVoteButton.isScrolled = false
//        }
//    }
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        makeVoteButton.isScrolled = false
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        makeVoteButton.isScrolled = scrollView.contentOffset.y > 0
    }
}

extension VoteViewController: BaseViewControllerDelegate {
    func navigateToMyPage() {
        coordinator?.navigateToMyPage(self.navigationController, tabBarCoordinator: coordinator?.tabBarCoordinator)
    }
}
