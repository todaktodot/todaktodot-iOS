//
//  UserDTO.swift
//  todaktodot
//
//  Created by 임대진 on 2/14/26.
//

import Foundation

struct UserDTO: Codable {
    let userId: Int
    let nickname: String?
    let role: String
    let infoAlarmYN: String
    let adAlarmYN: String
    let marketingAlarmYN: String
    let isTerm: String
    let isCouple: String
    let coupleType: String?
    let delYn: String
    let coupleDetailInfo: CoupleDetailInfoDTO?
}

struct CoupleDetailInfoDTO: Codable {
    let coupleId: Int
    let loginUserId: Int
    let loginNickname: String?
    let anotherUserId: Int
    let anotherNickname: String?
    let firstMetDt: String?
    let sinceMetDt: String?
    let relationshipStage: String?
    let connectedDt: String
    let delYn: String
}

extension UserDTO {
    func toUserInfo() -> UserInfo {
        UserInfo(
            userId: userId,
            coupleId: coupleDetailInfo?.coupleId,
            isTerm: isTerm == "Y",
            isCouple: isCouple == "Y",
            coupleType: CoupleType(rawValue: coupleType?.uppercased() ?? "") ?? .null,
            createdMyNickname: nickname != nil,
            createdCoupleInfo: coupleDetailInfo?.relationshipStage != nil
        )
    }
    
    func toMypageInfo() -> MypageInfo {
        MypageInfo(
            myNickname: nickname ?? "",
            partnerNickname: coupleDetailInfo?.anotherNickname,
            isCouple: CoupleType(rawValue: coupleType?.uppercased() ?? "") == .connected,
            coupleInfo: CoupleInfo(
                firstMetDate: dateToKR(coupleDetailInfo?.firstMetDt) ?? "",
                sinceMetDate: coupleDetailInfo?.sinceMetDt ?? "",
                stage: CoupleStage(rawValue: coupleDetailInfo?.relationshipStage ?? "")?.title ?? ""
            ),
            infoAgree: infoAlarmYN == "Y",
            advertAgree: adAlarmYN == "Y",
            marketingAgree: marketingAlarmYN == "Y"
        )
    }
    
    func setUserDefaultUserInfo() {
        UserdefaultKey.userId = userId
        UserdefaultKey.coupleId = coupleDetailInfo?.coupleId
        UserdefaultKey.joined = isTerm == "Y"
        UserdefaultKey.couple = isCouple == "Y"
        UserdefaultKey.coupleType = CoupleType(rawValue: coupleType?.uppercased() ?? "") ?? .null
        UserdefaultKey.createdMyNickname = nickname != nil
        UserdefaultKey.createdCoupleInfo = coupleDetailInfo?.relationshipStage != nil
    }
    
    func dateToKR(_ dateString: String?) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        
        guard let dateString = dateString, let date = formatter.date(from: dateString) else { return nil }

        formatter.dateFormat = "yyyy년 M월 d일"

        return formatter.string(from: date)
    }
}

