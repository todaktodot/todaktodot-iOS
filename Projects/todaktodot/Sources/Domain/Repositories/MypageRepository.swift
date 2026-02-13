//
//  MypageRepository.swift
//  todaktodot
//
//  Created by 임대진 on 2/14/26.
//

import RxSwift

protocol MypageRepository {
    func disconnectCouple() -> Observable<Bool>
}
