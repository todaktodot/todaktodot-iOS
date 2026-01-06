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

final class AIReportViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    private let scrollView = UIScrollView().then {
        $0.bounces = false
        $0.showsVerticalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    private let contentContainer = UIImageView().then {
        $0.image = UIImage(resource: .aiReportBackground)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
    }
    
    private let segmentView = UIView()
    
    private let lastWeekButton = UIButton().then {
        $0.setTitle("지난 한 주", for: .normal)
        $0.setTitleColor(.grayScale600, for: .normal)
        $0.setTitleColor(.grayScale900, for: .selected)
        $0.titleLabel?.font = UIFont.pretenSemiBold(16)
        $0.isSelected = true
    }
    
    private let storageButton = UIButton().then {
        $0.setTitle("돌아보기", for: .normal)
        $0.setTitleColor(.grayScale600, for: .normal)
        $0.setTitleColor(.grayScale900, for: .selected)
        $0.titleLabel?.font = UIFont.pretenSemiBold(16)
        $0.isSelected = false
    }
    
    private let underLineView = UIView().then {
        $0.backgroundColor = .grayScale200
    }
    
    private let selectedLineView = UIView().then {
        $0.backgroundColor = .grayScale900
    }
    
    private let lineContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupFlexLayout()
        bindActions()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentContainer)
    }
    
    private func setupFlexLayout() {
        contentContainer.flex.define {
            $0.addItem(segmentView)
                .marginTop(100)
                .marginHorizontal(20)
                .height(45)
            
            $0.addItem(lineContainer)
                .marginTop(10)
                .marginHorizontal(20)
                .height(2)
            
            $0.addItem(underLineView)
                .marginTop(0)
                .horizontally(20)
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
        
        lineContainer.flex.define { flex in
            flex.addItem(selectedLineView)
                .position(.absolute)
                .top(0)
                .left(0)
                .height(2)
        }
    }
    
    private func layoutViews() {
        scrollView.pin.all()
        
        contentContainer.pin
            .top()
            .horizontally()
            .height(contentContainer.image?.size.height ?? 1743)
        
        contentContainer.flex.layout()
        
        layoutSelectedLine(index: 0)
        
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.width,
            height: contentContainer.frame.maxY
        )
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        
        let logoImageView = UIImageView(image: UIImage(resource: .appLogo))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: 92, height: 32)
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 92 + 20, height: 32))
        logoContainer.addSubview(logoImageView)
        logoImageView.frame.origin.x = 0
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoContainer)
        
        let personImageView = UIImageView(image: UIImage(resource: .person))
        personImageView.contentMode = .scaleAspectFit
        personImageView.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        let personContainer = UIView(frame: CGRect(x: 0, y: 0, width: 18 + 20, height: 18))
        personContainer.addSubview(personImageView)
        personImageView.frame.origin.x = 20
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: personContainer)
    }
    
    private func bindActions() {
        lastWeekButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                lastWeekButton.isSelected = true
                storageButton.isSelected = false
                
                layoutSelectedLine(index: 0)
            })
            .disposed(by: disposeBag)

        storageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                lastWeekButton.isSelected = false
                storageButton.isSelected = true
               
                layoutSelectedLine(index: 1)
            })
            .disposed(by: disposeBag)
    }
    
    private func layoutSelectedLine(index: Int) {
        let half = lineContainer.bounds.width / 2
        let x = index == 0 ? 0 : half

        let apply = {
            self.selectedLineView.frame = CGRect(x: x,y: 0,width: half,height: 2)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: apply)
    }
}
