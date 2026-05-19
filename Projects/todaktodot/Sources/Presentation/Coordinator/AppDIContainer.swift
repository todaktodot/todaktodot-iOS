//
//  HomeCoordinator.swift
//  todaktodot
//
//  Created by daye on 4/21/26.
//

import Foundation
import NetworkKit

final class AppDIContainer {
    static let shared = AppDIContainer()
    private init() {}
    
    // MARK: - Network
    private lazy var networkManager = NetworkManager.shared
    
    // MARK: - Repositories
    private lazy var authRepository: AuthRepository = AuthRepositoryImpl(
        kakaoAuthProvider: KakaoAuthProvider(),
        googleAuthProvider: GoogleAuthProvider(),
        appleAuthProvider: AppleAuthProvider(),
        networkManager: networkManager
    )
    
    private lazy var cardRepository: CardRepository = CardRepositoryImpl(
        networkManager: networkManager
    )
    
    private lazy var coupleRepository: CoupleRepository = CoupleRepositoryImpl(
        networkManager: networkManager
    )
    
    private lazy var mypageRepository: MypageRepository = MypageRepositoryImpl(
        networkManager: networkManager
    )
    
    private lazy var aiReportRepository: AIReportRepository = AIReportRepositoryImpl(
        networkManager: networkManager
    )
    
    // MARK: - Use Cases
    private lazy var loginUseCase = LoginUseCase(repository: authRepository)
    private lazy var cardUseCase = CardUseCase(repository: cardRepository)
    private lazy var coupleUseCase = CoupleUseCase(repository: coupleRepository)
    private lazy var mypageUseCase = MypageUsecase(repository: mypageRepository)
    private lazy var aiReportUseCase = AIReportUseCase(repository: aiReportRepository)
}

// MARK: - Make Reactor
extension AppDIContainer {
    func makeHomeReactor() -> HomeReactor {
        HomeReactor(cardUseCase: cardUseCase, loginUseCase: loginUseCase, coupleUseCase: coupleUseCase)
    }
    
    func makeSigninReactor() -> SigninReactor {
        SigninReactor(loginUseCase: loginUseCase)
    }
    
    func makeCoupleReactor() -> CoupleReactor {
        CoupleReactor(coupleUseCase: coupleUseCase)
    }
    
    func makeDailyCardReactor(dailyCards: [QuestionCard], selectedType: CardType) -> DailyCardReactor {
        DailyCardReactor(cardUseCase: cardUseCase, dailyCards: dailyCards, selectedType: selectedType)
    }
    
    func makeHistoryCardDetailReactor(card: QuestionCard) -> HistoryCardDetailReactor {
        HistoryCardDetailReactor(cardUseCase: cardUseCase, card: card)
    }
    
    func makeAIReportReactor() -> AIReportReactor {
        AIReportReactor(useCase: aiReportUseCase)
    }
    
    func makeMyPageReactor() -> MyPageReactor {
        MyPageReactor(mypageUsecase: mypageUseCase)
    }
}
