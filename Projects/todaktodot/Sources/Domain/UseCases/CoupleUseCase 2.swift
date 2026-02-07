//
//  CoupleUseCase 2.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//


import Foundation
import RxSwift

// 1. 인터페이스 정의
protocol CoupleUseCase {
    func issueCode() -> Observable<CoupleCode>
    func connectCouple(code: String) -> Observable<Bool>
    func setNickname(nickname: String) -> Observable<Bool>
    func setCoupleInfo(date: Date, stage: String) -> Observable<Bool> // Date 객체 사용
}

final class CoupleUseCaseImpl: CoupleUseCase {
    private let repository: CoupleRepository

    init(repository: CoupleRepository) {
        self.repository = repository
    }
    
    func issueCode() -> Observable<CoupleCode> {
        return repository.issueCode()
    }
    
    func connectCouple(code: String) -> Observable<Bool> {
        return repository.connectCouple(code: code)
    }
    
    func setNickname(nickname: String) -> Observable<Bool> {
        // 예: 닉네임 글자 수 검증 로직을 여기서 처리할 수 있음
        return repository.setNickname(nickname: nickname)
    }
    
    func setCoupleInfo(date: Date, stage: String) -> Observable<Bool> {
        // 서버가 원하는 String 포맷으로 여기서 변환!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        return repository.setCoupleInfo(date: dateString, stage: stage)
    }
}