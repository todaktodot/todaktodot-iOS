//
//  TabBarType.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import UIKit

enum TabBarType: Int, CaseIterable {
    case home = 0
    case aiReport = 1
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .aiReport:
            return "AI 리포트"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "house")
        case .aiReport:
            return UIImage(systemName: "sparkles")
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .home:
            return UIImage(systemName: "house.fill")
        case .aiReport:
            return UIImage(systemName: "sparkles")
        }
    }
}
