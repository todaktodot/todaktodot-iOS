//
//  Notification.swift
//  todaktodot
//
//  Created by 임대진 on 2/17/26.
//

import Foundation

extension Notification.Name {
    public static let logoutRequired = Notification.Name("logoutRequired")
    public static let connectedCouple = Notification.Name("connectedCouple")
    public static let sceneWillEnterForeground = Notification.Name("sceneWillEnterForeground")
}
