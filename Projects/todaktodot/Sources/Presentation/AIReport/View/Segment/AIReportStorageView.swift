//
//  AIReportStorageView.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//


import UIKit
import PinLayout
import FlexLayout
import Then
import Lottie

final class AIReportStorageView: UIView {
    var onCardTap: ((Int) -> Void)?
    
    private var monthButtons: [MonthButton] = []
    private var selectedMonth: Int = 1
    private var listData: [AIReportList]? = nil
    private let titleLabel = TDLabel().then {
        $0.text = "지난 우리의 대화를\nAI 리포트로 확인해보세요"
        $0.font = .pretenSemiBold(24)
        $0.textColor = .grayScale900
        $0.numberOfLines = 2
    }
    
    private let yearButton = ImageTextButton(spacing: 4, imageSize: 12, imageFirst: false).then {
        $0.customText.text = "2026년"
        $0.customText.font = .pretenSemiBold(18)
        $0.customImage.image = UIImage(systemName: "chevron.down")
        $0.customImage.tintColor = .black
        
        let item = UIAction(title: "2026년", handler: { _ in
        })
        
        $0.menu = UIMenu(title: "년도 선택", children: [item])
        $0.showsMenuAsPrimaryAction = true
    }
    
    private let monthScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
    }
    private let monthContentView = UIView()
    private let cards: [AIReportWeekCardView] = [
        AIReportWeekCardView(),
        AIReportWeekCardView(),
        AIReportWeekCardView(),
        AIReportWeekCardView()
    ]
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupViews()
        setupMonthButtons()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthContentView.flex.layout(mode: .adjustWidth)
        monthScrollView.contentSize = monthContentView.frame.size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(listData: [AIReportList]) {
        self.listData = listData
        configCards(listData: listData)
    }
    
    private func setupViews() {
        self.flex.define {
            $0.addItem(titleLabel)
                .marginTop(12)
            
            $0.addItem(yearButton)
                .marginTop(32)
                .alignSelf(.center)
            
            $0.addItem(monthScrollView)
                .marginTop(20)
                .marginHorizontal(-20)
            
            cards.forEach { card in
                card.onTap = { [weak self] reportId in
                    self?.onCardTap?(reportId)
                }
            }
            
            $0.addItem().marginTop(20).define { flex in
                for (index, card) in cards.enumerated() {
                    flex.addItem(card)
                        .height(index == 3 ? 62 : 62 + 31)
                        .marginTop(index != 0 ? -31 : 0)
                        .marginHorizontal(0)
                }
            }
        }
        
        monthScrollView.addSubview(monthContentView)
    }
    
    private func setupMonthButtons() {
        let months = Array(1...Calendar.current.component(.month, from: Date()))
        
        monthButtons = months.map {
            let button = MonthButton(month: $0)
            button.addTarget(self, action: #selector(monthTapped(_:)), for: .touchUpInside)
            return button
        }
        monthButtons.first?.update(selected: selectedMonth)
        
        monthContentView.flex
            .direction(.row)
            .gap(8)
            .define { flex in
                monthButtons.forEach { button in
                    flex.addItem(button)
                        .marginLeft(button.month == 1 ? 20 : 0)
                        .height(40)
                        .width(60)
                        .paddingHorizontal(19.5)
                        .paddingVertical(10)
                }
            }
    }
    
    private func updateMonthButtons(_ sender: MonthButton) {
        selectedMonth = sender.month
        monthButtons.forEach { $0.update(selected: sender.month) }
        let targetX =
        sender.center.x
        - monthScrollView.bounds.width / 2
        
        let maxOffsetX =
        monthScrollView.contentSize.width
        - monthScrollView.bounds.width
        
        let offsetX = max(0, min(targetX, maxOffsetX))
        
        monthScrollView.setContentOffset(
            CGPoint(x: offsetX, y: 0),
            animated: true
        )
    }
    
    private func configCards(listData: [AIReportList]) {
        for weekNumber in (1...4) {
            if let report = listData.first(where: {
                $0.month == selectedMonth &&
                $0.week == weekNumber
            }) {
                cards[weekNumber - 1].configure(
                    month: selectedMonth,
                    week: weekNumber,
                    isActive: true,
                    reportId: report.reportId
                )
            } else {
                cards[weekNumber - 1].configure(
                    month: selectedMonth,
                    week: weekNumber,
                    isActive: false
                )
            }
        }
    }
    
    private func updateCards() {
        guard let listData else {
            for i in 0..<4 {
                cards[i].configure(
                    month: selectedMonth,
                    week: i + 1,
                    isActive: false
                )
            }
            flex.layout()
            return
        }
        
        configCards(listData: listData)
        
        flex.layout()
    }
    
    @objc private func monthTapped(_ sender: MonthButton) {
        updateMonthButtons(sender)
        updateCards()
    }
}
