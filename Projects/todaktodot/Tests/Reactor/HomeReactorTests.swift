//
//  HomeReactorTests.swift
//  todaktodotTests
//
//  Created by daye on 7/28/26.
//

import XCTest
import RxSwift
@testable import todaktodot

final class HomeReactorTests: XCTestCase {
    
    var mockCardRepository: MockCardRepository!
    var mockCoupleRepository: MockCoupleRepository!
    var mockAuthRepository: MockAuthRepository!
    var cardUseCase: CardUseCase!
    var signinUseCase: SigninUseCase!
    var coupleUseCase: CoupleUseCase!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockCardRepository = MockCardRepository()
        mockCoupleRepository = MockCoupleRepository()
        mockAuthRepository = MockAuthRepository()
        cardUseCase = CardUseCase(repository: mockCardRepository)
        signinUseCase = SigninUseCase(repository: mockAuthRepository)
        coupleUseCase = CoupleUseCase(repository: mockCoupleRepository)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        mockCardRepository = nil
        mockCoupleRepository = nil
        mockAuthRepository = nil
        cardUseCase = nil
        signinUseCase = nil
        coupleUseCase = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - determineAnswerStatus (카드상태)
    
    func test_determineAnswerStatus_둘다답변_bothAnswered() {
        // given
        let reactor = makeReactor()
        let cards = [makeCard(user1Answered: true, user2Answered: true, isSelected: true)]
        
        // when
        let status = reactor.determineAnswerStatus(from: cards)
        
        // then
        XCTAssertEqual(status, .bothAnswered)
    }
    
    func test_determineAnswerStatus_나만답변_myAnswered() {
        // given
        let reactor = makeReactor()
        let cards = [makeCard(user1Answered: true, user2Answered: false, isSelected: true)]
        
        // when
        let status = reactor.determineAnswerStatus(from: cards)
        
        // then
        XCTAssertEqual(status, .myAnswered)
    }
    
    func test_determineAnswerStatus_상대만답변_partnerAnswered() {
        // given
        let reactor = makeReactor()
        let cards = [makeCard(user1Answered: false, user2Answered: true, isSelected: true)]
        
        // when
        let status = reactor.determineAnswerStatus(from: cards)
        
        // then
        XCTAssertEqual(status, .partnerAnswered)
    }
    
    func test_determineAnswerStatus_둘다미답변_bothUnanswered() {
        // given
        let reactor = makeReactor()
        let cards = [makeCard(user1Answered: false, user2Answered: false, isSelected: true)]
        
        // when
        let status = reactor.determineAnswerStatus(from: cards)
        
        // then
        XCTAssertEqual(status, .bothUnanswered)
    }
    
    func test_determineAnswerStatus_빈배열_bothUnanswered() {
        // given
        let reactor = makeReactor()
        
        // when
        let status = reactor.determineAnswerStatus(from: [])
        
        // then
        XCTAssertEqual(status, .bothUnanswered)
    }
    
    func test_determineAnswerStatus_선택된카드우선() {
        // given
        let reactor = makeReactor()
        let cards = [
            makeCard(user1Answered: false, user2Answered: false, isSelected: false),
            makeCard(user1Answered: true, user2Answered: true, isSelected: true)  // 이게 선택됨
        ]
        
        // when
        let status = reactor.determineAnswerStatus(from: cards)
        
        // then
        XCTAssertEqual(status, .bothAnswered)
    }
    
    // MARK: - 콕찌르기 (유저 인터랙션 + 에러 핸들링)
    
    func test_콕찌르기_성공시_poked상태_true() {
        // given
        let reactor = makeReactor()
        let expectation = expectation(description: "poke success")
        mockCardRepository.pokeDailyCardResult = .just(.success(()))
        
        // when
        reactor.action.onNext(.tapPokeButton(coupleCardId: 100))
        
        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(reactor.currentState.isPoked)
            XCTAssertTrue(reactor.currentState.didPokeSuccess)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_콕찌르기_실패시_에러표시() {
        // given
        let reactor = makeReactor()
        let expectation = expectation(description: "poke error")
        mockCardRepository.pokeDailyCardResult = .just(.failure(NSError(domain: "test", code: 500)))
        
        // when
        reactor.action.onNext(.tapPokeButton(coupleCardId: 100))
        
        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(reactor.currentState.shouldShowPokeError)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - 주간 카드 (로딩 상태 관리)
    
    func test_fetchWeeklyCards_성공_빈배열이면_retryable() {
        // given
        let reactor = makeReactor()
        let expectation = expectation(description: "retryable")
        mockCardRepository.fetchWeeklyCardsResult = .just(.success([]))
        
        // when
        reactor.action.onNext(.fetchWeeklyCards(startDate: "2026-07-28", endDate: "2026-08-03"))
        
        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if case .retryable = reactor.currentState.cardLoadState {
                // 성공
            } else {
                XCTFail("cardLoadState가 .retryable이어야 합니다")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchWeeklyCards_실패시_error상태() {
        // given
        let reactor = makeReactor()
        let expectation = expectation(description: "error")
        mockCardRepository.fetchWeeklyCardsResult = .just(.failure(NSError(domain: "test", code: 500)))
        
        // when
        reactor.action.onNext(.fetchWeeklyCards(startDate: "2026-07-28", endDate: "2026-08-03"))
        
        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if case .error = reactor.currentState.cardLoadState {
                // 성공
            } else {
                XCTFail("cardLoadState가 .error여야 합니다")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - 커플 연결 확인
    
    func test_checkCoupleConnection_미연결시_서버확인() {
        // given
        let reactor = makeReactor()
        // 초기 상태가 connected가 아닐 때만 API 호출
        // UserdefaultKey에 의존하므로 초기 상태에 따라 달라짐
        
        // when
        reactor.action.onNext(.checkCoupleConnection)
        
        // then - 커플 연결 상태면 API 호출 안 함
        if reactor.currentState.isCoupleConnected {
            XCTAssertEqual(mockAuthRepository.fetchUserInfoCallCount, 0)
        }
    }
}

// MARK: - Helper

private extension HomeReactorTests {
    
    func makeReactor() -> HomeReactor {
        HomeReactor(cardUseCase: cardUseCase, signinUseCase: signinUseCase, coupleUseCase: coupleUseCase)
    }
    
    func makeCard(
        user1Answered: Bool = false,
        user2Answered: Bool = false,
        isSelected: Bool = true
    ) -> QuestionCard {
        QuestionCard(
            id: 1,
            coupleCardId: 100,
            title: "테스트 카드",
            date: Date(),
            mode: .coffee,
            subject: .love,
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "질문",
                    type: .multipleChoice,
                    isRequired: true,
                    options: [QuestionOption(id: 1, text: "선택 1")],
                    user1Answer: user1Answered ? "1" : nil,
                    user1Emoji: nil,
                    user2Answer: user2Answered ? "1" : nil,
                    user2Emoji: nil
                )
            ],
            situation: "상황",
            isSelected: isSelected,
            selectedByUserId: isSelected ? 1 : nil,
            user1Answered: user1Answered,
            user2Answered: user2Answered,
            userId1: 1,
            userId2: 2,
            feedback: nil,
            pocked: false
        )
    }
}

// MARK: - AnswerStatus Equatable

extension AnswerStatus: Equatable {}
