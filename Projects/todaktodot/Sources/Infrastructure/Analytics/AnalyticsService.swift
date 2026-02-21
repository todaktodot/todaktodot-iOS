//
//  AnalyticsService.swift
//  todaktodot
//
//  Created by 임대진 on 2/21/26.
//

import Foundation
import FirebaseAnalytics


final class AnalyticsService {
    /// 커플 연결 진입
    func beginningCoupleConnect() {
        Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: [
            "step": "couple_connect_entry",
            "screen_name": "couple_connect"
        ])
    }
    
    /// 코드 복사 방식을 선택했을 때
    func coupleCodeCopy() {
        Analytics.logEvent("couple_connect", parameters: [
            "method": "copy",
            "screen_name": "couple_connect"
        ])
    }
    
    /// 코드를 입력했을 때
    func coupleCodeWrite() {
        Analytics.logEvent("couple_connect", parameters: [
            "method": "code",
            "screen_name": "couple_connect"
        ])
    }
    
    /// 커플 연결 완료
    func coupleConnectSuccess() {
        Analytics.logEvent("couple_connect_completed", parameters: [:])
    }
    
    /// 닉네임 입력 진입
    func nicknameInputEntry() {
        Analytics.logEvent("nickname_set_view", parameters: [:])
    }
    
    /// 닉네임 입력 완료
    func nicknameInputSuccess() {
        Analytics.logEvent("nickname_set_completed", parameters: [
            "button_type": "next_button"
        ])
    }
    
    /// 커플 기본정보 입력 완료
    func coupleBasicInfoInputSuccess() {
        Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: [
            "step": "start_button_clicked",
            "screen_name": "couple_info_set_view"
        ])
    }
}
