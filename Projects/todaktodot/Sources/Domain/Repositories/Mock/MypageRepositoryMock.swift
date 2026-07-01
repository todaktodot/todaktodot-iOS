////
////  MypageRepositoryMock.swift
////  todaktodot
////
////  Created by 임대진 on 2/14/26.
////
//
//import RxSwift
//import NetworkKit
//import Alamofire
//
//final class MypageRepositoryMock: MypageRepository {
//    func fetchInfo() -> Observable<MypageInfo> {
//        .just(MypageInfo(myNickname: "a", partnerNickname: "a", isCouple: true, coupleInfo: CoupleInfo(firstMetDate: "", sinceMetDate: "", stage: ""), infoAgree: true, advertAgree: true, marketingAgree: true))
//    }
//    
//    func logout() -> Observable<Void> {
//        .just(())
//    }
//    
//    func disconnectCouple() -> Observable<Bool> {
//        .just(true)
//    }
//    
//    func withdrawal() -> Observable<Bool> {
//        .just(true)
//    }
//    
//    func deleteDeviceToken() -> Observable<Void> {
//        .just(())
//    }
//    
//    func updateTerms(infoAgree: Bool? = nil, marketingAgree: Bool? = nil, advertiesmentAgree: Bool? = nil) -> Observable<Bool> {
//        .just(true)
//    }
//}
