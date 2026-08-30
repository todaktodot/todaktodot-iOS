//
//  WebhookManager.swift
//  todaktodot
//
//  Created by daye on 7/28/26.
//

import Foundation

enum WebhookManager {
    
    private static let webhookURL: String = {
        guard let value = Bundle.main.infoDictionary?["DISCORD_WEBHOOK_URL"] as? String else { return "" }
        return value.removingPercentEncoding ?? value
    }()
    
    // MARK: - Public
    
    /// Discord에 에러 embed 메시지를 전송합니다.
    /// - Parameters:
    ///   - title: embed 타이틀 (예: "📍 AI 피드백 생성 실패")
    ///   - fields: embed fields 배열 [["name": "이름", "value": "값", "inline": false]]
    ///   - color: embed 색상 (기본: 빨간색 15158332)
    static func send(
        title: String,
        fields: [[String: Any]],
        color: Int = 15158332
    ) {
        guard let url = URL(string: webhookURL), !webhookURL.isEmpty else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "embeds": [[
                "title": title,
                "color": color,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "footer": ["text": "🍎 iOS"],
                "fields": fields
            ]]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request).resume()
    }
    
    /// AI 피드백 실패 전용 웹훅
    static func sendFeedbackError(
        reason: String,
        coupleCardId: Int,
        cardId: Int,
        issuedDate: String,
        statusCode: String = "",
        message: String = ""
    ) {
        let fields: [[String: Any]] = [
            ["name": "원인", "value": reason, "inline": false],
            ["name": "요청 API", "value": "/api/feedback/generate", "inline": false],
            ["name": "coupleId", "value": "\(UserdefaultKey.coupleId ?? -1)", "inline": false],
            ["name": "request body", "value": "```json\n{\n  \"coupleCardId\": \(coupleCardId),\n  \"cardId\": \(cardId),\n  \"issuedDate\": \"\(issuedDate)\"\n}\n```", "inline": false],
            ["name": "response", "value": "```json\n{\n  \"statusCode\": \(statusCode),\n  \"message\": \"\(message)\"\n}\n```", "inline": false],
        ]
        
        send(title: "📍 AI 피드백 생성 실패", fields: fields)
    }
}
