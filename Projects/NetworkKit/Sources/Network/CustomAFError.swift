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
    let message: String
    
    public var isAlreadyCouple: Bool {
        return message == APIErrorMessages.aleardyCouple.rawValue
    }
}

struct APIErrorResponse: Decodable {
    let message: String
}

public enum APIErrorMessages: String {
    case aleardyCouple = "이미 커플인 유저입니다"
}
