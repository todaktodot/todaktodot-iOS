//
//  CustomAFError.swift
//  NetworkKit
//
//  Created by 임대진 on 2/20/26.
//

import Foundation
internal import Alamofire

public struct CustomAFError: Error {
    let underlyingError: AFError
    public let message: String
    public let errorCode: String?
    public let statusCode: Int?
    
    public var isAlreadyCouple: Bool {
        return message == APIErrorMessages.aleardyCouple.rawValue
    }
    
    public var isAleardySolo: Bool {
        return message == APIErrorMessages.aleardySolo.rawValue
    }
    
    /// 서버 에러 코드 (enum)
    public var apiErrorCode: APIErrorCode? {
        guard let errorCode else { return nil }
        return APIErrorCode(rawValue: errorCode)
    }
    
    /// 네트워크 미연결 여부 (오프라인)
    public var isNotConnected: Bool {
        if case .sessionTaskFailed(let error) = underlyingError,
           let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .timedOut:
                return true
            default:
                return false
            }
        }
        return false
    }
}

struct APIErrorResponse: Decodable {
    let message: String
    let code: String?
}

public enum APIErrorMessages: String {
    case aleardyCouple = "이미 커플인 유저입니다"
    case aleardySolo = "이미 등록된 상태입니다. 커플 연결 또는 혼자 둘러보기가 진행 중입니다."
}
