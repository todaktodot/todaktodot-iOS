//
//  InfiniteSliderView.swift
//  todaktodot
//
//  Created by 임대진 on 12/12/25.
//

import UIKit
import FlexLayout
import PinLayout

final class InfiniteSliderView: UIView {
    
    private let slideInterval: TimeInterval = 4.0
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl().then {
        $0.pageIndicatorTintColor = UIColor(hex: "000000").withAlphaComponent(0.15)
        $0.currentPageIndicatorTintColor = .mainPurple
        
        $0.isUserInteractionEnabled = false
    }
    
    private var images: [UIImage] = [UIImage(resource: .onboarding1), UIImage(resource: .onboarding2), UIImage(resource: .onboarding3)]
    private var timer: Timer?
    private var loopImages: [UIImage] = []
    private var currentPage: Int = 0 {
        didSet { pageControl.currentPage = currentPage }
    }

    init() {
        super.init(frame: .zero)
        setupLoopImages()
        setupUI()
        setupScrollView()
        startTimer()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupLoopImages() {
        guard let first = images.first, let last = images.last else { return }
        
        loopImages = [last] + images + [first]
        pageControl.numberOfPages = 3
    }

    private func setupUI() {
        addSubview(scrollView)
        addSubview(pageControl)
    }

    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        loopImages.forEach { img in
            let v = UIImageView(image: img)
            v.contentMode = .scaleAspectFill
            v.clipsToBounds = true
            scrollView.addSubview(v)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.pin.all()
        pageControl.pin
            .bottom(300)
            .hCenter()
            .height(10)
            .width(80)
        
        layoutScrollViews()
    }

    private func layoutScrollViews() {
        let w = scrollView.bounds.width
        let h = scrollView.bounds.height
        
        for (i, view) in scrollView.subviews.enumerated() {
            view.frame = CGRect(x: CGFloat(i) * w, y: 0, width: w, height: h)
        }
        
        scrollView.contentSize = CGSize(width: w * CGFloat(loopImages.count), height: h)
        
        scrollView.setContentOffset(CGPoint(x: w, y: 0), animated: false)
        currentPage = 0
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: slideInterval, target: self, selector: #selector(slideNext), userInfo: nil, repeats: true)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func slideNext() {
        let w = scrollView.bounds.width
        let nextOffset = scrollView.contentOffset.x + w
        
        scrollView.setContentOffset(CGPoint(x: nextOffset, y: 0), animated: true)
    }
}


extension InfiniteSliderView: UIScrollViewDelegate {
    
    // 사용자가 손으로 드래그 시작, 자동 슬라이드 정지
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }

    // 스크롤 종료 후, 인덱스 맞추기 + 무한 루프 처리 + 다시 자동슬라이드 시작
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustInfiniteScroll()
        startTimer()
    }

    // 애니메이션 자동 이동이 끝났을 때 호출
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        adjustInfiniteScroll()
    }

    private func adjustInfiniteScroll() {
        let w = scrollView.bounds.width
        let x = scrollView.contentOffset.x
        let index = Int(x / w)
        
        if index == 0 {
            scrollView.setContentOffset(CGPoint(x: w * CGFloat(images.count), y: 0), animated: false)
            currentPage = images.count - 1
        } else if index == loopImages.count - 1 {
            scrollView.setContentOffset(CGPoint(x: w, y: 0), animated: false)
            currentPage = 0
        } else {
            currentPage = index - 1
        }
    }
}
