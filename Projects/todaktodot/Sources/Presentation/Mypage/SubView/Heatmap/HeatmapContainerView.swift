//
//  ActivityHeatmapView.swift
//  todaktodot
//
//  Created by 임대진 on 7/1/26.
//

import UIKit
import FlexLayout
import PinLayout
import Then
import RxRelay
import RxSwift

final class HeatmapContainerView: UIView {
    
    var displayYear = BehaviorRelay<Int>(value: Calendar.current.component(.year, from: Date()))
    
    let infoButton = UIButton().then {
        $0.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        $0.tintColor = .grayScale400
    }
    
    private let disposeBag = DisposeBag()
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        cal.minimumDaysInFirstWeek = 4
        return cal
    }()
    private let titleLabel = TDLabel().then {
        $0.text = "우리의 활동"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale700
    }
    
    private let yearButton = ImageTextButton(horizonPadding: 0, verticalPadding: 0, spacing: 4, imageSize: 12, imageFirst: false).then {
        $0.customText.font = .pretenSemiBold(18)
        $0.customImage.image = UIImage(systemName: "chevron.down")
        $0.customImage.tintColor = .black
        $0.showsMenuAsPrimaryAction = true
    }
    
    private let heatmapColorPaletteImageView = UIImageView(image: UIImage(resource: .heatmapColorPalette))
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceHorizontal = true
    }
    
    private let contentView = UIView()
    private let activityHeatmapView = ActivityHeatmapView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 16
        
        setupYearMenu()
        bindYear()
        setupViews()
        setupFlexLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    private func makeLabel(text: String) -> TDLabel {
        return TDLabel().then {
            $0.text = text
            $0.font = .pretenRegular(14)
            $0.textColor = .grayScale400
            $0.textAlignment = .left
        }
    }
    
    private func setupViews() {
        scrollView.addSubview(contentView)
        contentView.addSubview(activityHeatmapView)
    }
    
    private func bindYear() {
        displayYear
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] year in
                guard let self else { return }
                self.yearButton.customText.text = "\(year)년"
                self.yearButton.flex.markDirty()
                
                // TODO: 새로고침 추가
            })
            .disposed(by: disposeBag)
    }
    
    private func setupYearMenu() {
        let items = (2026...displayYear.value).map { year in
            UIAction(title: "\(year)년", handler: { [weak self] _ in
                self?.displayYear.accept(year)
            })
        }

        yearButton.menu = UIMenu(title: "년도 선택", children: items)
    }
    
    private func setupFlexLayout() {
        self.flex.define {
            $0.addItem()
                .direction(.row)
                .height(32)
                .marginTop(16)
                .marginBottom(16)
                .paddingHorizontal(20)
                .alignItems(.center)
                .define {
                    $0.addItem(titleLabel)
                    $0.addItem(infoButton)
                        .size(16)
                        .marginLeft(4)
                    $0.addItem()
                        .grow(1)
                    $0.addItem(yearButton)
                }
            
            $0.addItem()
                .height(1)
                .backgroundColor(.grayScale100)
            
            $0.addItem()
                .height(221)
                .direction(.row)
                .define {
                    $0.addItem(scrollView)
                        .grow(1)
                    
                    $0.addItem()
                        .marginTop(44)
                        .marginLeft(16)
                        .marginRight(24)
                        .gap(5)
                        .direction(.column)
                        .define { flex in
                            ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].forEach {
                                flex.addItem(makeLabel(text: $0))
                            }
                        }
                }
            
            $0.addItem(heatmapColorPaletteImageView)
                .marginVertical(20)
                .alignSelf(.center)
        }
    }
    
    private func layoutViews() {
        let size = activityHeatmapView.intrinsicContentSize

        activityHeatmapView.frame = CGRect(
            x: 20,
            y: 21,
            width: size.width,
            height: size.height
        )

        contentView.frame = CGRect(
            x: 0,
            y: 0,
            width: activityHeatmapView.frame.maxX,
            height: 221
        )
        
        scrollView.contentSize = contentView.bounds.size
        scrollToCurrentWeek()
    }
    
    private func column(for date: Date) -> Int {
        guard let startOfYear = calendar.date(from: DateComponents(year: displayYear.value, month: 1, day: 1)) else {
            return 0
        }

        let firstWeek = calendar.component(.weekOfYear, from: startOfYear)

        var week = calendar.component(.weekOfYear, from: date)

        if week < firstWeek {
            week += calendar.range(of: .weekOfYear, in: .yearForWeekOfYear, for: startOfYear)?.count ?? 52
        }

        return week - firstWeek
    }
    
    private func scrollToCurrentWeek() {
        let today = Date()

        let currentColumn = column(for: today)

        let cell: CGFloat = 20
        let spacing: CGFloat = 6
        let step = cell + spacing

        let targetColumn = currentColumn + 1

        let rightPadding = cell * 4 + spacing * 2 + 2 // 이번달 영역

        let x = CGFloat(targetColumn) * step
            - (scrollView.bounds.width - rightPadding)

        let maxOffset = max(0, scrollView.contentSize.width - scrollView.bounds.width)

        scrollView.setContentOffset(
            CGPoint(x: min(max(0, x), maxOffset), y: 0),
            animated: false
        )
    }
    
    func configure(heatmap: ActivityHeatmap) {
        activityHeatmapView.configure(year: displayYear.value, heatmap: heatmap)
    }
}
