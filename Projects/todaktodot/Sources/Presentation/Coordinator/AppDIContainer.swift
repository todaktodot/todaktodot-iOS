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
    
    private lazy var shareLinkRepository: ShareLinkRepository = ShareLinkRepositoryImpl(
        networkManager: networkManager
    )
    
    private lazy var voteRepository: VoteRepository = VoteRepositoryImpl(
        networkManager: networkManager
    )
    
    // MARK: - Use Cases
    private lazy var signinUseCase = SigninUseCase(repository: authRepository)
    private lazy var cardUseCase = CardUseCase(repository: cardRepository)
    private lazy var coupleUseCase = CoupleUseCase(repository: coupleRepository)
    private lazy var mypageUseCase = MypageUseCase(repository: mypageRepository)
    private lazy var aiReportUseCase = AIReportUseCase(repository: aiReportRepository)
    private lazy var onboardingUseCase = OnboardingUseCase(repository: mypageRepository)
    private lazy var shareLinkUseCase = ShareLinkUseCase(repository: shareLinkRepository)
    private lazy var voteUseCase = VoteUseCase(repository: voteRepository)
}

// MARK: - Network Access
extension AppDIContainer {
    func makeNetworkManager() -> NetworkManager {
        networkManager
    }
}

// MARK: - Make Reactor
extension AppDIContainer {
    func makeHomeReactor() -> HomeReactor {
        HomeReactor(cardUseCase: cardUseCase, signinUseCase: signinUseCase, coupleUseCase: coupleUseCase)
    }
    
    func makeSigninReactor() -> SigninReactor {
        SigninReactor(signinUseCase: signinUseCase, onboardingUseCase: onboardingUseCase)
    }
    
    func makeCoupleReactor() -> CoupleReactor {
        CoupleReactor(coupleUseCase: coupleUseCase, onboardingUseCase: onboardingUseCase)
    }
    
    func makeDailyCardReactor(dailyCards: [QuestionCard], selectedType: CardType) -> DailyCardReactor {
        DailyCardReactor(cardUseCase: cardUseCase, dailyCards: dailyCards, selectedType: selectedType)
    }
    
    func makeHistoryCardDetailReactor(card: QuestionCard) -> HistoryCardDetailReactor {
        HistoryCardDetailReactor(cardUseCase: cardUseCase, shareLinkUseCase: shareLinkUseCase, card: card)
    }
    
    func makeShareLinkUseCase() -> ShareLinkUseCase {
        shareLinkUseCase
    }
    
    func makeCardUseCase() -> CardUseCase {
        cardUseCase
    }
    
    func makeAIReportReactor() -> AIReportReactor {
        AIReportReactor(useCase: aiReportUseCase)
    }
    
    func makeMyPageReactor() -> MyPageReactor {
        MyPageReactor(mypageUsecase: mypageUseCase)
    }
    
    func makeMypageUseCase() -> MypageUseCase {
        mypageUseCase
    }
    
    func makeVoteReactor() -> VoteReactor {
        VoteReactor(useCase: voteUseCase)
    }
    
    func makeVoteUseCase() -> VoteUseCase {
        voteUseCase
    }
}

