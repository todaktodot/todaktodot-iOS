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
    private var cards: [AIReportWeekCardView] = []
    private var lastWeek: Int = 1
    private var selectedYear: Int = 2026 {
        didSet {
            yearButton.customText.text = "\(selectedYear)년"
            // TODO: 년도 변경시 로직 추가하기
        }
    }
    private var selectedMonth: Int = 1 {
        didSet {
            lastWeek = displayWeekInfo(month: selectedMonth).week
        }
    }
    
    private var listData: [AIReportList]? = nil {
        didSet {
            configCards(listData: listData)
        }
    }
    
    private var monthCalendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = .current
        return calendar
    }
    
    private let titleLabel = TDLabel().then {
        $0.text = "지난 우리의 대화를\nAI 리포트로 확인해보세요"
        $0.font = .pretenSemiBold(24)
        $0.textColor = .grayScale900
        $0.numberOfLines = 2
    }
    
    private let yearButton = ImageTextButton(spacing: 4, imageSize: 12, imageFirst: false).then { // TODO: 2027년 선택 로직
        $0.customText.font = .pretenSemiBold(18)
        $0.customImage.image = UIImage(systemName: "chevron.down")
        $0.customImage.tintColor = .black
        $0.showsMenuAsPrimaryAction = true
    }
    
    private let today = Date()
    private let cardsContentView = UIView()
    private let monthsContentView = UIView()
    private let monthScrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        let currentYear = monthCalendar.component(.year, from: today)
        selectedYear = currentYear
        setMenu(year: currentYear)
        
        let prev = displayWeekInfo()
        selectedMonth = prev.month
        lastWeek = prev.week
        cards = (0..<lastWeek).map { _ in AIReportWeekCardView() }
        
        setupViews()
        setupMonthButtons()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthsContentView.flex.layout(mode: .adjustWidth)
        monthScrollView.contentSize = monthsContentView.frame.size
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(listData: [AIReportList]) {
        let calendar = monthCalendar
        let mapData = listData.map {
            var data = $0
            
            if data.week > 1 {
                data.week -= 1
            } else {
                var components = DateComponents()
                components.year = selectedYear
                components.month = data.month
                components.day = 1
                
                if let currentDate = calendar.date(from: components),
                   let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
                    
                    let prevMonth = calendar.component(.month, from: prevMonthDate)
                    data.month = prevMonth
                    data.week = toLastWeekCount(month: prevMonth)
                }
            }
            
            return data
        }
        self.listData = mapData
    }
    
    func setMenu(year: Int) {
        let currentYear = monthCalendar.component(.year, from: Date())
        let item = (2026...currentYear).map { [weak self] year in
            UIAction(title: "\(year)년", handler: { [weak self] _ in
                self?.selectedYear = year
            })
        }
        
        yearButton.customText.text = "\(year)년"
        yearButton.menu = UIMenu(title: "년도 선택", children: item)
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
            
            $0.addItem(cardsContentView)
                .marginTop(20)
        }
        
        cardsContentView.flex.define { flex in
            for (displayIndex, weekNumber) in (1...lastWeek).reversed().enumerated() {
                let card = cards[weekNumber - 1]
                flex.addItem(card)
                    .height(displayIndex == (lastWeek-1) ? 62 : 62 + 31)
                    .marginTop(displayIndex != 0 ? -31 : 0)
                    .marginHorizontal(0)
            }
        }
        
        monthScrollView.addSubview(monthsContentView)
    }
    
    private func setupMonthButtons() {
        monthButtons.removeAll()
        monthsContentView.subviews.forEach { $0.removeFromSuperview() }
        
        let currentYear = monthCalendar.component(.year, from: Date())
        let currentMonth = monthCalendar.component(.month, from: Date())
        
        let maxMonth = (selectedYear == currentYear) ? currentMonth : 12
        let months = Array(1...maxMonth)
        
        monthButtons = months.map {
            let button = MonthButton(month: $0)
            button.addTarget(self, action: #selector(monthTapped(_:)), for: .touchUpInside)
            return button
        }
        
        monthButtons.first { $0.month == currentMonth }?.update(selected: currentMonth)
        
        monthsContentView.flex
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
        
        monthsContentView.flex.markDirty()
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
    
    private func configCards(listData: [AIReportList]?) {
        guard let listData else {
            return
        }
        for weekNumber in (1...lastWeek) {
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
        
        cards.forEach { card in
            card.onTap = { [weak self] reportId in
                self?.onCardTap?(reportId)
            }
        }
        
        cardsContentView.flex.markDirty()
    }
    
    private func updateCards() {
        cards = (0..<lastWeek).map { _ in AIReportWeekCardView() }
        
        guard let listData else {
            for i in 0..<lastWeek-1 {
                cards[i].configure(
                    month: selectedMonth,
                    week: i + 1,
                    isActive: false
                )
            }
            return
        }
        
        cardsContentView.subviews.forEach { $0.removeFromSuperview() }
        
        cardsContentView.flex.define { flex in
            for (displayIndex, weekNumber) in (1...lastWeek).reversed().enumerated() {
                let card = cards[weekNumber - 1]
                flex.addItem(card)
                    .height(displayIndex == (lastWeek-1) ? 62 : 62 + 31)
                    .marginTop(displayIndex != 0 ? -31 : 0)
                    .marginHorizontal(0)
            }
        }
        
        configCards(listData: listData)
        flex.layout()
    }
    
    func displayWeekInfo(month: Int? = nil) -> (month: Int, week: Int) {
        let calendar = monthCalendar
        let currentYear = calendar.component(.year, from: today)
        let currentWeek = calendar.component(.weekOfMonth, from: today)
        let currentMonth = calendar.component(.month, from: today)
        let targetMonth = month ?? currentMonth
        
        if targetMonth == currentMonth && currentYear == selectedYear {
            if currentWeek > 1 {
                return (currentMonth, currentWeek - 1)
            }
            
            guard let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: today) else {
                return (currentMonth, 1)
            }
            
            let prevMonth = calendar.component(.month, from: prevMonthDate)
            return (prevMonth, toLastWeekCount(month: prevMonth))
        }
        
        return (targetMonth, toLastWeekCount(month: targetMonth))
    }
    
    func toLastWeekCount(month: Int) -> Int {
        let calendar = monthCalendar
        
        var components = DateComponents()
        components.year = selectedYear
        components.month = month
        components.day = 1
        
        guard let firstDate = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDate) else {
            return 0
        }
        
        components.day = range.count
        guard let lastDate = calendar.date(from: components) else {
            return 0
        }
        
        return calendar.component(.weekOfMonth, from: lastDate)
    }
    
    @objc private func monthTapped(_ sender: MonthButton) {
        updateMonthButtons(sender)
        updateCards()
    }
}
