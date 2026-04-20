//
//  CustomTabBarView.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa

final class CustomTabBarView: UIView {
   
    private let backgroundView = UIView()
    private let selectionIndicator = UIView()
    private let flexContainer = UIView()
    private var tabViews: [TabItemView] = []
    
    private let disposeBag = DisposeBag()
    private var currentSelectedIndex = 0
    
    let selectedTabIndex = PublishRelay<Int>()
    
    private let tabBarHeight: CGFloat = 60
    private let horizontalMargin: CGFloat = 44
    private let indicatorInset: CGFloat = 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundView.backgroundColor = TodotColors.Grayscale.grayScale900
        backgroundView.layer.cornerRadius = tabBarHeight / 2
        
        selectionIndicator.backgroundColor = TodotColors.Grayscale.white
        selectionIndicator.layer.cornerRadius = (tabBarHeight - indicatorInset * 2) / 2
        
        TabBarType.allCases.forEach { tabType in
            let tabView = TabItemView(tabType: tabType)
            tabViews.append(tabView)
        }
        
        addSubview(backgroundView)
        addSubview(selectionIndicator)
        addSubview(flexContainer)
        tabViews.forEach { flexContainer.addSubview($0) }
        
        flexContainer.flex
            .direction(.row)
            .justifyContent(.spaceAround)
            .alignItems(.center)
            .define { flex in
                tabViews.forEach { tabView in
                    flex.addItem(tabView).grow(1).shrink(1)
                }
            }
        
        updateSelection(at: 0, animated: false)
    }
    
    private func setupBindings() {
        tabViews.enumerated().forEach { index, tabView in
            tabView.tapGesture
                .subscribe(onNext: { [weak self] in
                    self?.selectTab(at: index)
                })
                .disposed(by: disposeBag)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > 0 else { return }
        
        backgroundView.pin
            .horizontally(horizontalMargin)
            .top()
            .height(tabBarHeight)
        
        flexContainer.pin
            .horizontally(horizontalMargin)
            .top()
            .height(tabBarHeight)
        
        flexContainer.flex.layout()
        
        updateSelectionIndicatorPosition(animated: false)
    }
    
    private func selectTab(at index: Int) {
        guard index != currentSelectedIndex else { return }
        
        updateSelection(at: index, animated: true)
        selectedTabIndex.accept(index)
    }
    
    private func updateSelection(at index: Int, animated: Bool) {
        currentSelectedIndex = index
        
        // Update tab states
        tabViews.enumerated().forEach { tabIndex, tabView in
            tabView.setSelected(tabIndex == index)
        }
        
        updateSelectionIndicatorPosition(animated: animated)
    }
    
    private func updateSelectionIndicatorPosition(animated: Bool) {
        let buttonWidth = (bounds.width - horizontalMargin * 2) / CGFloat(tabViews.count)
        let indicatorX = horizontalMargin + CGFloat(currentSelectedIndex) * buttonWidth + indicatorInset
        let indicatorWidth = buttonWidth - indicatorInset * 2
        let indicatorHeight = tabBarHeight - indicatorInset * 2
        
        let updateBlock = { [weak self] in
            guard let self = self else { return }
            self.selectionIndicator.pin
                .left(indicatorX)
                .width(indicatorWidth)
                .top(indicatorInset)
                .height(indicatorHeight)
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseInOut],
                animations: updateBlock
            )
        } else {
            updateBlock()
        }
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool = false) {
        guard index >= 0 && index < TabBarType.allCases.count else { return }
        updateSelection(at: index, animated: animated)
    }
}

private final class TabItemView: UIView {
    
    private let contentContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = TDLabel()
    private let tabType: TabBarType
    
    let tapGesture = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    init(tabType: TabBarType) {
        self.tabType = tabType
        super.init(frame: .zero)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.image = tabType.icon
        iconImageView.tintColor = TodotColors.Grayscale.grayScale400
        
        titleLabel.text = tabType.title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = TodotColors.Grayscale.grayScale400
        
        addSubview(contentContainer)
        contentContainer.addSubview(iconImageView)
        contentContainer.addSubview(titleLabel)
        
        contentContainer.flex
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .paddingLeft(22)
            .define { flex in
                flex.addItem(iconImageView).width(tabType.iconSize.width).height(tabType.iconSize.height)
                flex.addItem(titleLabel).marginLeft(8)
            }
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer()
        addGestureRecognizer(tap)
        
        tap.rx.event
            .map { _ in () }
            .bind(to: tapGesture)
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentContainer.pin.all()
        contentContainer.flex.layout()
    }
    
    func setSelected(_ isSelected: Bool) {
        iconImageView.image = isSelected ? tabType.selectedIcon : tabType.icon
        iconImageView.tintColor = isSelected ? TodotColors.Grayscale.grayScale900 : TodotColors.Grayscale.grayScale400
        titleLabel.textColor = isSelected ? TodotColors.Grayscale.grayScale900 : TodotColors.Grayscale.grayScale400
    }
}
