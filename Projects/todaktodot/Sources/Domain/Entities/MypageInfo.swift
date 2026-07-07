//
//  MypageInfo.swift
//  todaktodot
//
//  Created by 임대진 on 2/14/26.
//

import Foundation

struct MypageInfo: Equatable {
    let myNickname: String
    let partnerNickname: String?
    let isCouple: Bool
    let coupleInfo: CoupleInfo
    let infoAgree: Bool
    let advertAgree: Bool
    let marketingAgree: Bool
}
