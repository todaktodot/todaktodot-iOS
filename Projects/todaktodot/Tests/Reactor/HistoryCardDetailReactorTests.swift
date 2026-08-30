//
//  HistoryCardDetailReactorTests.swift
//  todaktodotTests
//
//  Created by daye on 7/28/26.
//

import XCTest
import RxSwift
@testable import todaktodot

final class HistoryCardDetailReactorTests: XCTestCase {
    
    var mockCardRepository: MockCardRepository!
    var mockShareLinkRepository: MockShareLinkRepository!
    var cardUseCase: CardUseCase!
    var shareLinkUseCase: ShareLinkUseCase!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        // 테스트 간 UserDefaults 오염 방지
        UserdefaultKey.feedbackActionHistory = [:]
        
        mockCardRepository = MockCardRepository()
        mockShareLinkRepository = MockShareLinkRepository()
        cardUseCase = CardUseCase(repository: mockCardRepository)
        shareLinkUseCase = ShareLinkUseCase(repository: mockShareLinkRepository)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        UserdefaultKey.feedbackActionHistory = [:]
        mockCardRepository = nil
        mockShareLinkRepository = nil
        cardUseCase = nil
        shareLinkUseCase = nil
        disposeBag = nil
        super.tearDown()
    }
    
    // MARK: - 초기 상태 결정 (핵심 분기 로직)
    
    func test_초기상태_피드백있으면_loaded() {
        // given
        let feedback = makeFeedback()
        let card = makeCard(feedback: feedback)
        
        // when
        let reactor = makeReactor(card: card)
        
        // then
        if case .loaded(let f) = reactor.currentState.feedbackState {
            XCTAssertEqual(f.summary, "좋은 대화였어요")
        } else {
            XCTFail("feedbackState가 .loaded여야 합니다. 실제: \(reactor.currentState.feedbackState)")
        }
    }
    
    func test_초기상태_한명만답변이면_locked() {
        // given
        let card = makeCard(user1Answered: true, user2Answered: false)
        
        // when
        let reactor = makeReactor(card: card)
        
        // then
        if case .locked = reactor.currentState.feedbackState {
            // 성공
        } else {
            XCTFail("feedbackState가 .locked여야 합니다. 실제: \(reactor.currentState.feedbackState)")
        }
    }
    
    func test_초기상태_둘다미답변이면_locked() {
        // given
        let card = makeCard(user1Answered: false, user2Answered: false)
        
        // when
        let reactor = makeReactor(card: card)
        
        // then
        if case .locked = reactor.currentState.feedbackState {
            // 성공
        } else {
            XCTFail("feedbackState가 .locked여야 합니다")
        }
    }
    
    func test_초기상태_둘다답변했고_이력없으면_generating() {
        // given
        let card = makeCard(user1Answered: true, user2Answered: true, feedback: nil)
        
        // when
        let reactor = makeReactor(card: card)
        
        // then
        if case .generating = reactor.currentState.feedbackState {
            // 성공
        } else {
            XCTFail("feedbackState가 .generating이어야 합니다. 실제: \(reactor.currentState.feedbackState)")
        }
    }
    
    // MARK: - 이모지 저장/삭제 (유저 인터랙션)
    
    func test_saveEmoji_상태업데이트_및_API호출() {
        // given
        let card = makeCard(date: Date())
        let reactor = makeReactor(card: card)
        
        // when
        reactor.action.onNext(.saveEmoji(.heart))
        
        // then
        XCTAssertEqual(reactor.currentState.myEmoji, .heart)
        XCTAssertEqual(mockCardRepository.saveEmojiCallCount, 1)
        XCTAssertEqual(mockCardRepository.saveEmojiLastType, .heart)
    }
    
    func test_deleteEmoji_상태nil_및_API호출() {
        // given
        let card = makeCard(user2Emoji: .heart, date: Date())
        let reactor = makeReactor(card: card)
        
        // when
        reactor.action.onNext(.deleteEmoji)
        
        // then
        XCTAssertNil(reactor.currentState.myEmoji)
        XCTAssertEqual(mockCardRepository.deleteEmojiCallCount, 1)
    }
    
    func test_이번주아닌카드_이모지저장_무시됨() {
        // given
        let oldDate = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!
        let card = makeCard(date: oldDate)
        let reactor = makeReactor(card: card)
        
        // when
        reactor.action.onNext(.saveEmoji(.good))
        
        // then
        XCTAssertEqual(mockCardRepository.saveEmojiCallCount, 0)
    }
    
    // MARK: - 공유 링크 (에러 핸들링)
    
    func test_createShareLink_성공시_URL설정() {
        // given
        let card = makeCard()
        let reactor = makeReactor(card: card)
        let expectation = expectation(description: "shareURL")
        
        // when
        reactor.action.onNext(.createShareLink)
        
        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(reactor.currentState.shareURL, "https://todaktodot.com/share/abc")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_createShareLink_실패시_에러상태() {
        // given
        mockShareLinkRepository.createShareLinkResult = .just(.failure(NSError(domain: "test", code: 500)))
        let card = makeCard()
        let reactor = makeReactor(card: card)
        let expectation = expectation(description: "shareError")
        
        // when
        reactor.action.onNext(.createShareLink)
        
        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(reactor.currentState.shareError, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - 피드백 폴링 (비동기 로직)
    
    func test_checkFeedback_이미loaded면_폴링안함() {
        // given
        let card = makeCard(feedback: makeFeedback())
        let reactor = makeReactor(card: card)
        
        // when
        reactor.action.onNext(.checkFeedback)
        
        // then
        XCTAssertEqual(mockCardRepository.fetchFeedbackStatusCallCount, 0)
    }
    
    func test_regenerate_API실패시_error상태() {
        // given
        mockCardRepository.generateFeedbackResult = .just(.failure(NSError(domain: "test", code: 500)))
        let card = makeCard(user1Answered: true, user2Answered: true)
        let reactor = makeReactor(card: card)
        let expectation = expectation(description: "regenerate error")
        
        // when
        reactor.action.onNext(.regenerate)
        
        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if case .error = reactor.currentState.feedbackState {
                // 성공
            } else {
                XCTFail("feedbackState가 .error여야 합니다")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Helper

private extension HistoryCardDetailReactorTests {
    
    func makeReactor(card: QuestionCard) -> HistoryCardDetailReactor {
        HistoryCardDetailReactor(cardUseCase: cardUseCase, shareLinkUseCase: shareLinkUseCase, card: card)
    }
    
    func makeCard(
        id: Int = 1,
        coupleCardId: Int = 100,
        user1Answered: Bool = true,
        user2Answered: Bool = true,
        feedback: CardFeedback? = nil,
        user1Emoji: EmojiType? = nil,
        user2Emoji: EmojiType? = nil,
        date: Date = Date()
    ) -> QuestionCard {
        QuestionCard(
            id: id,
            coupleCardId: coupleCardId,
            title: "테스트 카드",
            date: date,
            mode: .coffee,
            subject: .love,
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "어떤 선택을 하시겠어요?",
                    type: .multipleChoice,
                    isRequired: true,
                    options: [QuestionOption(id: 1, text: "선택 1"), QuestionOption(id: 2, text: "선택 2")],
                    user1Answer: "1",
                    user1Emoji: user1Emoji,
                    user2Answer: "2",
                    user2Emoji: user2Emoji
                ),
                Question(
                    number: 2,
                    content: "이유를 적어주세요",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: "이유1",
                    user1Emoji: nil,
                    user2Answer: "이유2",
                    user2Emoji: nil
                )
            ],
            situation: "테스트 상황",
            isSelected: true,
            selectedByUserId: 1,
            user1Answered: user1Answered,
            user2Answered: user2Answered,
            userId1: 1,
            userId2: 2,
            feedback: feedback,
            pocked: false
        )
    }
    
    func makeFeedback() -> CardFeedback {
        CardFeedback(
            id: 1,
            summary: "좋은 대화였어요",
            matchPoints: "두 분 다 대화를 중요시해요",
            differences: "표현 방식이 달라요",
            tip: "서로의 방식을 존중해보세요"
        )
    }
}
