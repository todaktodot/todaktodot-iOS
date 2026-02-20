//
//  MypageRepository.swift
//  todaktodot
//
//  Created by 임대진 on 2/14/26.
//

import RxSwift

protocol MypageRepository {
    func fetchInfo() -> Observable<MypageInfo>
    func logout() -> Observable<Bool>
    func disconnectCouple() -> Observable<Bool>
    func withdrawal() -> Observable<Bool>
}
