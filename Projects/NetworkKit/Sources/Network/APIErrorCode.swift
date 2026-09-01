//
//  APIErrorCode.swift
//  NetworkKit
//
//  Created by daye on 8/31/26.
//

import Foundation

/// 서버에서 내려주는 에러 코드
public enum APIErrorCode: String {
    // MARK: - Vote
    case closedVote = "V1001"           // 이미 마감된 투표
    case voteHasParticipant = "V1002"   // 참여자가 있어 수정 불가
    case dailyVoteLimitExceeded = "V1003" // 당일 생성 횟수 초과
    case voteBlockedByReport = "V1004"  // 신고 누적으로 생성 불가
    case voteHiddenByReport = "V1005"   // 신고 누적으로 숨김 처리된 투표
    case alreadyReportedVote = "V1006"  // 이미 신고한 투표
    case deletedVote = "V1007"          // 이미 삭제된 투표
    case notFoundVote = "V1008"         // 존재하지 않는 투표
    
    // MARK: - Common
    case serverError = "C1001"          // 서버 오류
    
    /// 서버 에러 메시지
    public var message: String {
        switch self {
        case .closedVote:            return "이미 마감된 투표입니다."
        case .voteHasParticipant:    return "참여자가 있는 투표는 수정할 수 없습니다."
        case .dailyVoteLimitExceeded: return "당일 생성할 수 있는 투표 수를 초과했습니다."
        case .voteBlockedByReport:   return "신고 누적으로 인해 투표를 생성할 수 없습니다."
        case .voteHiddenByReport:    return "신고 누적으로 숨김 처리된 투표입니다."
        case .alreadyReportedVote:   return "이미 신고한 투표입니다."
        case .deletedVote:           return "이미 삭제된 투표입니다."
        case .notFoundVote:          return "존재하지 않는 투표입니다."
        case .serverError:           return "서버 오류가 발생했습니다."
        }
    }
}
