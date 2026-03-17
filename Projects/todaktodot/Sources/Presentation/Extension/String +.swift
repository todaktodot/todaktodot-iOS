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

extension String {
    ///  text.replacingNicknames([("유저1", user1Name), ("유저2", user2Name)])
    /// - Parameter replacements: [("유저1", "수박"), ("유저2", "감귤")] 형태
    func replacingNicknames(_ replacements: [(target: String, name: String)]) -> String {
        let josaMap: [(wrong: String, correct: String)] = [
            ("라서", "이라서"), ("라고", "이라고"), ("라면", "이라면"),
            ("라는", "이라는"), ("이니까", "이니까"), ("니까", "이니까"),
            ("이랑", "이랑"), ("이나", "이나"),
            ("는", "은"), ("가", "이"), ("를", "을"), ("와", "과"),
            ("야", "아"), ("로", "으로"), ("나", "이나"), ("랑", "이랑"),
            ("란", "이란"), ("네", "이네"), ("다", "이다"), ("며", "이며")
        ]
        
        var result = self
        for (target, name) in replacements {
            let displayName = "\(name)님"
            for (wrong, correct) in josaMap {
                result = result.replacingOccurrences(of: "\(target)\(wrong)", with: "\(displayName)\(correct)")
            }
            result = result.replacingOccurrences(of: target, with: displayName)
        }
        return result
    }
}
