//
//  TabBarType.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import UIKit

enum TabBarType: Int, CaseIterable {
    case home = 0
    case vote = 1
    case aiReport = 2
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .vote:
            return "투표"
        case .aiReport:
            return "AI 리포트"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        case .vote:
            return UIImage(named: "vote")?.withRenderingMode(.alwaysTemplate)
        case .aiReport:
            return UIImage(named: "sparkle")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        case .vote:
            return UIImage(named: "vote")?.withRenderingMode(.alwaysTemplate)
        case .aiReport:
            return UIImage(named: "sparkle")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var iconSize: CGSize {
        switch self {
        case .home:
            return CGSize(width: 16.33, height: 16.33 * (72.0 / 66.0))
        case .vote:
            return CGSize(width: 24, height: 24)
        case .aiReport:
            return CGSize(width: 23.22, height: 23.22)
        }
    }
}
