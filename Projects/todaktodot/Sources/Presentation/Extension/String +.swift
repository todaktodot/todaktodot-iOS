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
    
    func toKRFomatter() -> String {
        guard let date = self.toDate() else {
            return self
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
    
    func toKRFomatterEMMDD() -> String {
        guard let date = self.toDate() else {
            return self
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "E MM월 dd일"
        return formatter.string(from: date)
    }
}
