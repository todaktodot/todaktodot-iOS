//
//  OnboardingInfoDTO.swift
//  todaktodot
//
//  Created by 임대진 on 6/30/26.
//

import Foundation

struct OnboardingInfoDTO: Codable {
    let userId: Int
    let nickname: String
    let birthDate: String
    let gender: String
    let message: String
}

extension OnboardingInfoDTO {
    func toInfo() -> OnboardingInfo {
        return OnboardingInfo(nickname: self.nickname, birthDate: self.birthDate, gender: self.gender == "M" ? .male : .female)
    }
}
