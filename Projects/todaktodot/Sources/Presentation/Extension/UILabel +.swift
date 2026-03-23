//
//  UILabel +.swift
//  todaktodot
//
//  Created by 임대진 on 12/3/25.
//

import UIKit

extension UILabel {
    func lastWeekRangeString() {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        let today = Date()
        
        guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: today) else { return }
        
        let weekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastWeek)
        
        guard let monday = calendar.date(from: weekComponents),
              let sunday = calendar.date(byAdding: .day, value: 6, to: monday)
        else { return }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        formatter.dateFormat = "yyyy년 M월 d일"
        let startString = formatter.string(from: monday)
        
        formatter.dateFormat = "M월 d일"
        let endString = formatter.string(from: sunday)
        
        self.text = "\(startString) - \(endString)"
    }
}
