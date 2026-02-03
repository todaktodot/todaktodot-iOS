////
////  CoupleInfo.swift
////  todaktodot
////
////  Created by 임대진 on 2/4/26.
////
//
//import Foundation
//
//struct CoupleInfo {
//    let connectedDate: Date
//    let firstMetDate: Date
//    let stage: CoupleStage
//}
//
//extension CoupleInfo {
//    init(dto: CoupleInfoDto) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        self.connectedDate = dateFormatter.date(from: dto.connectedDt) ?? Date()
//        self.firstMetDate = dateFormatter.date(from: dto.firstMetDt) ?? Date()
//        
//        self.stage = CoupleStage(rawValue: dto.relationshipStage) ?? .dating
//    }
//}
