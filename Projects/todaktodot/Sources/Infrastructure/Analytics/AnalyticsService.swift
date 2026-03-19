//
//  AnalyticsService.swift
//  todaktodot
//
//  Created by 임대진 on 2/21/26.
//

import Foundation
import FirebaseAnalytics

enum AnalyticsService {
    /// 권장 이벤트 표시 P 로 표기
    enum Event {
        // MARK: - 온보딩
        /// P 커플 연결 진입
        case coupleConnectBegin
        
        /// P 커플 연결
        case coupleConnect(method: CodeInputType)
        
        /// 커플 연결 완료 팝업
        case coupleConnectCompleted
        
        /// 닉네임 입력 진입
        case nicknameSetBegin
        
        /// 닉네임 입력 완료
        case nicknameSetCompleted
        
        /// 커플 기본정보 입력 진입
        case coupleInfoSetBegin
        
        /// P 커플 기본정보 입력 완료(시작하기 버튼 클릭)
        case coupleInfoSetCompleted
        
        /// 혼자 둘러볼게요 선택
        case soloStartSelect
        
        // MARK: - 데일리 카드
        
        /// P 데일리 카드 유형 선택 클릭
        case selectDailyCardType(cardId: Int, cardType: CardType)
        
        /// P 데일리 카드 상세 진입
        case dailyCardDetailBegin(cardId: Int)
        
        /// 답변 완료 팝업
        case dailyCardAnswerCompleted(cardId: Int)
        
        // MARK: - 히스토리 카드
        /// P 히스토리 카드 상세 진입
        case historyCardDetailBegin(cardId: Int)
        
        /// 히스토리 카드 유형
        case historyCardType(status: HistoryCardStatus)
        
        // MARK: - AI 리포트
        /// AI 리포트 내 탭 클릭/전환
        case reportSegmentTap(type: ReportSegment)
        
        /// 지난 한 주 AI 리포트 확인 버튼 클릭
        case lastWeekReportClick
        
        /// P AI 리포트 상세 진입
        case reportDetailBegin(reportId: Int)
        
        // MARK: - 가이드 툴팁
        /// P 가이드 툴팁 클릭
        case guideClick
        
        // MARK: - 푸시 알림
        /// 푸시 알림 클릭
        case pushOpen(type: PushType)
    }
    
    enum CodeInputType: String {
        case copy
        case keyboard = "code"
    }
    
    enum CardType: String {
        case situation = "situation_play"
        case balance = "balance_game"
    }
    
    enum HistoryCardStatus: String {
        case both = "both_answered"
        case mineOnly = "mine_only"
        case partnerOnly = "partner_only"
    }
    
    enum ReportSegment: String {
        case lastWeek = "last_week"
        case storage = "review"
    }
    
    enum PushType: String {
        case todayCardArrived = "question_arrived"
        case nudge = "partner_nudge"
        case partnerCompleted = "partner_arrived"
        case bothCompleted = "both_answered"
    }
    
    static func log(_ event: Event) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}

extension AnalyticsService.Event {
    var name: String {
        switch self {
        case .coupleConnectBegin:
            return AnalyticsEventTutorialBegin
        case .coupleConnect:
            return AnalyticsEventJoinGroup
        case .coupleConnectCompleted:
            return "couple_connect_completed"
        case .nicknameSetBegin:
            return "nickname_set_view"
        case .nicknameSetCompleted:
            return "nickname_set_completed"
        case .coupleInfoSetBegin:
            return "couple_info_set_view"
        case .coupleInfoSetCompleted:
            return AnalyticsEventTutorialComplete
        case .soloStartSelect:
            return "self_browse_select"
        case .selectDailyCardType:
            return AnalyticsEventSelectContent
        case .dailyCardDetailBegin:
            return AnalyticsEventViewItem
        case .dailyCardAnswerCompleted:
            return "dailycard_answer_completed"
        case .historyCardDetailBegin:
            return AnalyticsEventViewItem
        case .historyCardType:
            return "historycard_type"
        case .reportSegmentTap:
            return "view_report_tab"
        case .lastWeekReportClick:
            return "last_week_report_click"
        case .reportDetailBegin:
            return AnalyticsEventViewItem
        case .guideClick:
            return AnalyticsEventSelectContent
        case .pushOpen:
            return "push_open"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .coupleConnectBegin:
            return [
                "step": "couple_connect_entry",
                AnalyticsParameterScreenName: "couple_connect"
            ]

        case .coupleConnect(let method):
            return [
                AnalyticsParameterMethod: method.rawValue,
                AnalyticsParameterScreenName: "couple_connect"
            ]

        case .coupleConnectCompleted:
            return [
                AnalyticsParameterScreenName: "couple_connect_completer_popup"
            ]

        case .nicknameSetBegin:
            return [
                AnalyticsParameterScreenName: "nickname_set"
            ]

        case .nicknameSetCompleted:
            return [
                "trigger_element": "next_button"
            ]

        case .coupleInfoSetBegin:
            return [
                AnalyticsParameterScreenName: "couple_info_set"
            ]

        case .coupleInfoSetCompleted:
            return [
                "step": "start_button_clicked",
                AnalyticsParameterScreenName: "couple_info_set_view"
            ]

        case .soloStartSelect:
            return [
                "trigger_element": "self_browse_button"
            ]
            
        case .selectDailyCardType(let cardId, let cardType):
            return [
                AnalyticsParameterContentType: cardType.rawValue,
                AnalyticsParameterItemID: cardId,
                AnalyticsParameterScreenName: "dailycard_type_select"
            ]

        case .dailyCardDetailBegin(let cardId):
            return [
                AnalyticsParameterItemCategory: "daily_card",
                AnalyticsParameterItemID: cardId,
                AnalyticsParameterScreenName: "dailycard_detail"
            ]

        case .dailyCardAnswerCompleted(let cardId):
            return [
                AnalyticsParameterItemID: cardId,
                "answer_status": "both",
                AnalyticsParameterScreenName: "answer_completed_popup"
            ]

        case .historyCardDetailBegin(let cardId):
            return [
                AnalyticsParameterItemCategory: "history_card",
                AnalyticsParameterItemID: cardId,
                AnalyticsParameterScreenName: "historycard_detail"
            ]

        case .historyCardType(let status):
            return [
                "answer_status": status.rawValue
            ]

        case .reportSegmentTap(let type):
            return [
                "tab_name": type.rawValue
            ]

        case .lastWeekReportClick:
            return [
                "trigger_element": "check_button"
            ]

        case .reportDetailBegin(let reportId):
            return [
                AnalyticsParameterItemCategory: "ai_report",
                AnalyticsParameterItemID: reportId,
                AnalyticsParameterScreenName: "report_detail"
            ]

        case .guideClick:
            return [
                AnalyticsParameterContentType: "tooltip",
                AnalyticsParameterItemID: "가이드 툴팁"
            ]

        case .pushOpen(let type):
            return [
                "push_type": type.rawValue
            ]
        }
    }
}
