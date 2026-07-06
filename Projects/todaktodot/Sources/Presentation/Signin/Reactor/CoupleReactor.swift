//
//  CoupleReactor.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import ReactorKit
import Foundation

final class CoupleReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
        var mycode: String?
        var isJoined: Bool?
        var flowType: ConnectFlowType = .create
        
        var isAlreadyCouple: Bool?
        var isTermsAgreeSuccess: Bool?
        var isCoupleConnectSuccess: Bool?
        var isSoloStartSuccess: Bool?
        var isDisconnectSuccess: Bool?
        
        var outputNickname: String? // 닉네임 수정 완료 후 서버에서 받는 값 저장
        var inputNickname: String? // 현재 텍스트필드 닉네임 값
        var updateCoupleInfo: CoupleInfo?
        var gender: Gender? // M or F
        var birthday: String?
        var error: Error?
        
        var nicknameViewStep: NicknameViewStep = .nickname
    }
    
    enum NicknameViewStep {
        case nickname
        case birthday
        case gender
        case edit
    }
    
    enum Action {
        case issueCoupleCode
        case checkIsJoined
        
        case tapTemrsAgreeButton(Bool, Bool)
        case tapConnectButton(String)
        case tapStartButton(String, String)
        case tapSoloStartButton
        
        case tapNext
        case nicknameChanged(String)
        case birthdayChanged(String?)
        case genderChanged(Gender?)
        case isEditingOnly
        case disconnectCouple
    }
    
    enum Mutation {
        case setSoloStart(Bool)
        case setIsJoined(Bool)
        
        case setTermsAgreeSuccess(Bool)
        case setCoupleConnectSuccess(Bool)
        
        case setMyCode(String)
        case setNickname(String) // 닉네임 수정 후 저장
        case setCoupleInfo(CoupleInfo)
        
        case setAlreadyCouple
        case setError(Error?)
        
        case setStep(NicknameViewStep)
        case setBirthday(String?)
        case setGender(Gender?)
        
        case setCurrentNickname(String) // 닉네임 텍스트필드 변경될때 작동
        case setRoot
    }
    
    let initialState = State()
    
    private let coupleUseCase: CoupleUseCase
    
    init(coupleUseCase: CoupleUseCase) {
        self.coupleUseCase = coupleUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .issueCoupleCode:
            if UserdefaultKey.coupleType == .connected {
                return Observable.just(.setAlreadyCouple)
                    .observe(on: MainScheduler.asyncInstance)
            } else {
                return coupleUseCase.issueCode()
                    .map { Mutation.setMyCode($0.linkCode) }
                    .catch {
                        if let afError = $0.asCustomAFError, afError.isAlreadyCouple {
                            return .just(.setAlreadyCouple)
                        }
                        return .just(.setError($0))
                    }
            }
        case .tapConnectButton(let code):
            return coupleUseCase.connectCouple(code: code)
                .flatMap { _ -> Observable<Mutation> in
                    return self.assignCards()
                        .map { .setCoupleConnectSuccess($0) }
                        .catch { .just(.setError($0)) }
                }
                .catchAndReturn(.setCoupleConnectSuccess(false))
            
        case .tapStartButton(let date, let stage):
            return coupleUseCase.updateCoupleInfo(date: date, stage: stage)
                .map { Mutation.setCoupleInfo($0) }
            
        case .tapTemrsAgreeButton(let isMarketing, let isAdvertiesment):
            return coupleUseCase.setTerms(marketingAgree: isMarketing, advertiesmentAgree: isAdvertiesment)
                .map { Mutation.setTermsAgreeSuccess($0) }
                .catchAndReturn(Mutation.setTermsAgreeSuccess(false))
            
        case .checkIsJoined:
            return .just(.setIsJoined(UserdefaultKey.joined))
            
        case .tapSoloStartButton:
            if UserdefaultKey.coupleType != .null {
                return .just(.setSoloStart(true))
            } else {
                return coupleUseCase.soloStart()
                    .flatMap { _ -> Observable<Mutation> in
                        return self.assignCards()
                            .map { .setSoloStart($0) }
                            .catch { .just(.setError($0)) }
                    }
                    .catch {
                        if let afError = $0.asCustomAFError, afError.isAleardySolo {
                            return .just(.setSoloStart(true))
                        }
                        return .just(.setError($0))
                    }
            }
            
        case .tapNext:
            switch currentState.nicknameViewStep {
            case .nickname:
                return .just(.setStep(.birthday))

            case .birthday:
                return .just(.setStep(.gender))

            case .gender:
                return submitOnboarding()

            case .edit:
                return updateNickname()
            }
            
        case let .nicknameChanged(text):
            return .just(.setCurrentNickname(text))

        case let .birthdayChanged(date):
            return .just(.setBirthday(date))

        case let .genderChanged(gender):
            return .just(.setGender(gender))
            
        case .isEditingOnly:
            return .just(.setStep(.edit))
        case .disconnectCouple:
            return Observable.concat([
                coupleUseCase.disconnectCouple()
                    .flatMap { _ in
                        self.coupleUseCase.logout()
                    }
                    .map { _ in
                        .setRoot
                    }
            ])
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setMyCode(let code):
            newState.mycode = code
            
        case .setTermsAgreeSuccess(let isSuccess):
            newState.isTermsAgreeSuccess = isSuccess
            
        case .setCoupleConnectSuccess(let isSuccess):
            newState.isCoupleConnectSuccess = isSuccess
            
        case .setNickname(let nickname):
            newState.outputNickname = nickname
            
        case .setCoupleInfo(let info):
            newState.updateCoupleInfo = info
            
        case .setIsJoined(let isJoined):
            newState.isJoined = isJoined
            
        case .setAlreadyCouple:
            newState.isAlreadyCouple = true
            
        case .setSoloStart(let isSuccess):
            newState.isSoloStartSuccess = isSuccess
            
        case .setError(let error):
            newState.error = error
        case .setStep(let step):
            newState.nicknameViewStep = step
        case .setBirthday(let birthday):
            newState.birthday = birthday
        case .setGender(let gender):
            newState.gender = gender
            
        case .setCurrentNickname(let text):
            newState.inputNickname = text
        case .setRoot:
            newState.isDisconnectSuccess = true
        }
        
        return newState
    }
    
    private func submitOnboarding() -> Observable<Mutation> {
        guard let nickname = currentState.inputNickname,
              let birthday = currentState.birthday,
              let gender = currentState.gender
        else {
            return .empty()
        }

        return coupleUseCase
            .setOnboarding(info: .init(
                nickname: nickname,
                birthDate: birthday,
                gender: gender
            ))
            .map(Mutation.setNickname)
    }

    private func updateNickname() -> Observable<Mutation> {
        guard let nickname = currentState.inputNickname else {
            return .empty()
        }

        return coupleUseCase
            .updateNickname(nickname: nickname)
            .map(Mutation.setNickname)
    }
    
    private func assignCards() -> Observable<Bool> {
        let now = Date()
        
        var calendar = Calendar.current
        
        if let timeZone = TimeZone(identifier: "Asia/Seoul") {
            calendar.timeZone = timeZone
        }
        
        let hour = calendar.component(.hour, from: now)
        
        guard let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: now),
              let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: now) else {
            assertionFailure("Date 계산 실패")
            return self.coupleUseCase.assignCards(
                startDate: now.toYYYYMMDD(),
                endDate: now.toYYYYMMDD()
            )
        }
        
        switch hour {
        case 0..<4:
            return self.coupleUseCase.assignCards(
                startDate: yesterdayDate.toYYYYMMDD(),
                endDate: tomorrowDate.toYYYYMMDD()
            )
        default:
            return self.coupleUseCase.assignCards(
                startDate: now.toYYYYMMDD(),
                endDate: tomorrowDate.toYYYYMMDD()
            )
        }
    }
}
