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

final class ActivityHeatmapView: UIView {
    private var dayViews: [UIView] = []
    private var monthLabels: [UILabel] = []
    private var displayYear: Int = Calendar.current.component(.year, from: Date())
    
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        cal.minimumDaysInFirstWeek = 4
        return cal
    }()
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let cellSize: CGFloat = 20
        let spacing: CGFloat = 6

        let columns = Int(ceil(Double(dayViews.count) / 7.0))

        let width = CGFloat(columns) * cellSize
            + CGFloat(columns - 1) * spacing

        let height = 25 + 7 * cellSize
            + 6 * spacing

        return CGSize(width: width, height: height)
    }
    
    func configure(year: Int, heatmap: ActivityHeatmap) {
        if displayYear != year {
            displayYear = year
            rebuildDayViews()
        }

        for (index, view) in dayViews.enumerated() {
            view.frame = frameForDay(index)
        }

        for (month, label) in monthLabels.enumerated() {
            label.frame = frameForMonth(month + 1)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let year = displayYear

        guard let firstDay = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) else {
            return
        }

        for day in heatmap.days {
            guard let date = formatter.date(from: day.date) else { continue }

            let index = calendar.dateComponents([.day], from: firstDay, to: date).day ?? 0

            guard dayViews.indices.contains(index) else { continue }

            switch day.status {
            case .none:
                dayViews[index].backgroundColor = .grayScale100

            case .meOnly, .partnerOnly:
                dayViews[index].backgroundColor = .subPurple

            case .both:
                dayViews[index].backgroundColor = .mainPurple
            }
        }
    }
    
    private func setupViews() {
        for month in 1...12 {
            let label = UILabel()
            label.font = .pretenRegular(14)
            label.textColor = .grayScale400
            label.text = "\(month)월"
            addSubview(label)
            monthLabels.append(label)
        }
        
        rebuildDayViews()
    }
    
    private func rebuildDayViews() {
        dayViews.forEach { $0.removeFromSuperview() }
        dayViews.removeAll()

        let daysInYear = Calendar.current.range(
            of: .day,
            in: .year,
            for: Calendar.current.date(from: DateComponents(year: displayYear, month: 1, day: 1))!
        )!.count

        for index in 0..<daysInYear {
            let view = UIView()
            view.layer.cornerRadius = 1.6
            view.backgroundColor = .grayScale100
            view.frame = frameForDay(index)

            addSubview(view)
            dayViews.append(view)
        }

        monthLabels.forEach { bringSubviewToFront($0) }
        
        for (month, label) in monthLabels.enumerated() {
            label.frame = frameForMonth(month + 1)
        }
        
        invalidateIntrinsicContentSize()
    }
    
    private func column(for date: Date) -> Int {
        guard let startOfYear = calendar.date(from: DateComponents(year: displayYear, month: 1, day: 1)) else {
            return 0
        }

        let firstWeek = calendar.component(.weekOfYear, from: startOfYear)

        var week = calendar.component(.weekOfYear, from: date)

        if week < firstWeek {
            week += calendar.range(of: .weekOfYear, in: .yearForWeekOfYear, for: startOfYear)?.count ?? 52
        }

        return week - firstWeek
    }
    
    private func frameForDay(_ index: Int) -> CGRect {

        guard let startOfYear = calendar.date(from: DateComponents(year: displayYear, month: 1, day: 1)),
              let date = calendar.date(byAdding: .day, value: index, to: startOfYear) else {
            return .zero
        }

        let cellSize: CGFloat = 20
        let spacing: CGFloat = 6

        let column = column(for: date)
        let weekday = calendar.component(.weekday, from: date)
        let row = (weekday + 5) % 7

        let x = CGFloat(column) * (cellSize + spacing)
        let y = CGFloat(row) * (cellSize + spacing) + 25

        return CGRect(x: x, y: y, width: cellSize, height: cellSize)
    }
    
    private func frameForMonth(_ month: Int) -> CGRect {

        guard let firstDate = calendar.date(from: DateComponents(year: displayYear, month: month, day: 1)) else {
            return .zero
        }

        let cell: CGFloat = 20
        let spacing: CGFloat = 6

        let column = column(for: firstDate)

        return CGRect(
            x: CGFloat(column) * (cell + spacing),
            y: 0,
            width: 40,
            height: 17
        )
    }
}
