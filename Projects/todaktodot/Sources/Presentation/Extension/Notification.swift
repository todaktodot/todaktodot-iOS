//
//  Notification.swift
//  todaktodot
//
//  Created by 임대진 on 2/17/26.
//

import Foundation

extension Notification.Name {
    public static let logoutRequired = Notification.Name("logoutRequired")
    public static let coupleDisconnected = Notification.Name("coupleDisconnected")
    public static let connectionCompleteAndGoToNickname = Notification.Name("connectionCompleteAndGoToNickname")
    public static let sceneWillEnterForeground = Notification.Name("sceneWillEnterForeground")
    public static let partnerEmojiReceived = Notification.Name("partnerEmojiReceived")
    public static let cardAnswerStatusChanged = Notification.Name("cardAnswerStatusChanged")
}
