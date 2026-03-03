//
//  String+.swift
//  todaktodot
//
//  Created by daye on 2/10/26.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
    
    func toKRFomatter(excepYear: Bool = false) -> String {
        guard let date = self.toDate() else {
            return self
        }
        let formatter = DateFormatter()
        formatter.dateFormat = excepYear ? "M월 d일" : "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
    
    func toKRFomatterEMMDD() -> String {
        guard let date = self.toDate() else {
            return self
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "E M월 d일"
        return formatter.string(from: date)
    }
}
