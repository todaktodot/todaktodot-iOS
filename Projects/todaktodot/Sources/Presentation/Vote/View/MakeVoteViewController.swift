//
//  MakeVoteViewController.swift
//  todaktodot
//
//  Created by daye on 8/18/26.
//

import UIKit
import FlexLayout
import PinLayout
import RxSwift
import RxCocoa
import Then
import ReactorKit

final class MakeVoteViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    weak var coordinator: VoteCoordinator?
    
    // MARK: - UI
    
    private let scrollView = UIScrollView().then {
        $0.keyboardDismissMode = .interactive
        $0.showsVerticalScrollIndicator = false
    }
    
    private let contentContainer = UIView()
    
    private let topicTitleLabel = UILabel().then {
        $0.text = "주제"
        $0.font = .pretenSemiBold(14)
        $0.textColor = .grayScale600
    }
    
    private let topicContainer = UIView()
    
    private var topicButtons: [UIButton] = []
    
    private let questionTitleLabel = UILabel().then {
        $0.text = "질문"
        $0.font = .pretenSemiBold(14)
        $0.textColor = .grayScale600
    }
    
    private let questionTextView = UITextView().then {
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale900
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(hex: "E6E6E6").cgColor
        $0.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        $0.isScrollEnabled = true
        $0.returnKeyType = .done
    }
    
    private let questionPlaceholder = UILabel().then {
        $0.text = "어떤 질문을 작성해볼까요?"
        $0.font = .pretenMedium(16)
        $0.textColor = .grayScale400
    }
    
    private let questionCountLabel = UILabel().then {
        $0.font = .pretenRegular(12)
        $0.textColor = .grayScale400
        $0.text = "0/100"
        $0.numberOfLines = 1
    }
    
    private let answerTitleLabel = UILabel().then {
        $0.text = "답변"
        $0.font = .pretenSemiBold(14)
        $0.textColor = .grayScale600
    }
    
    private let answerContainer = UIView()
    
    private let addAnswerButton = UIButton(type: .system).then {
        $0.setTitle("+ 답변 항목 추가", for: .normal)
        $0.setTitleColor(.grayScale800, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(15)
        $0.backgroundColor = .grayScale100
        $0.layer.cornerRadius = 10
    }
    
    private let maxAnswerLabel = UILabel().then {
        $0.text = "*답변 항목은 최대 5개까지 가능해요"
        $0.font = .pretenMedium(14)
        $0.textColor = .grayScale400
    }
    
    private let customNavBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let navTitleLabel = UILabel().then {
        $0.text = "투표 만들기"
        $0.font = .pretenSemiBold(18)
        $0.textColor = .grayScale900
    }
    
    private let closeButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .grayScale900
    }
    
    private let submitButton = UIButton(type: .system).then {
        $0.setTitle("게시", for: .normal)
        $0.setTitleColor(.grayScale400, for: .normal)
        $0.titleLabel?.font = .pretenSemiBold(18)
        $0.isEnabled = false
    }
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupTopicButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigation()
        setupViews()
        setupKeyboardDismiss()
        setupKeyboardObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navBottom = customNavBar.frame.maxY
        scrollView.frame = CGRect(x: 0, y: navBottom, width: view.bounds.width, height: view.bounds.height - navBottom)
        contentContainer.pin.top().horizontally()
        
        contentContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentContainer.frame.size
    }
    
    // MARK: - Setup
    
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(customNavBar)
        customNavBar.addSubview(closeButton)
        customNavBar.addSubview(navTitleLabel)
        customNavBar.addSubview(submitButton)
        
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 44),
            
            closeButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            navTitleLabel.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            navTitleLabel.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            
            submitButton.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor, constant: -16),
            submitButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
        ])
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    @objc private func closeTapped() {
        let isEdit: Bool
        if let reactor = reactor {
            if case .edit = reactor.currentState.mode {
                isEdit = true
            } else {
                isEdit = false
            }
        } else {
            isEdit = false
        }
        
        showAlert(
            icon: UIImage(named: "Warning"),
            title: isEdit ? "수정을 그만둘까요?" : "작성을 그만둘까요?",
            description: "입력한 내용은 저장되지 않아요",
            primaryButtonTitle: "그만두기",
            primaryButtonAction: { [weak self] in
                self?.dismiss(animated: true)
            },
            secondaryButtonTitle: "계속 쓰기",
            secondaryButtonAction: {}
        )
    }
    
    private func setupTopicButtons() {
        topicContainer.flex.direction(.row).columnGap(6).define { flex in
            VoteTopic.allCases.enumerated().forEach { index, topic in
                let button = UIButton(type: .system).then {
                    $0.setTitle(topic.rawValue, for: .normal)
                    $0.setTitleColor(.grayScale700, for: .normal)
                    $0.titleLabel?.font = .pretenMedium(14)
                    $0.backgroundColor = .white
                    $0.layer.cornerRadius = 16
                    $0.layer.borderWidth = 1
                    $0.layer.borderColor = UIColor.grayScale200.cgColor
                    $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
                    $0.tag = index
                }
                topicButtons.append(button)
                flex.addItem(button).height(32)
            }
        }
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentContainer)
        
        contentContainer.flex.paddingHorizontal(20).paddingTop(18).define { flex in
            // 주제
            flex.addItem(topicTitleLabel).marginBottom(8)
            flex.addItem(topicContainer).marginBottom(16)
            
            // 질문
            flex.addItem(questionTitleLabel).marginBottom(8)
            flex.addItem().define { flex in
                flex.addItem(questionTextView).height(143)
                flex.addItem(questionPlaceholder).position(.absolute).top(14).left(16)
            }.marginBottom(4)
            flex.addItem(questionCountLabel).alignSelf(.end).marginBottom(16)
            
            // 답변
            flex.addItem(answerTitleLabel).marginBottom(8)
            flex.addItem(answerContainer).marginBottom(0)
            flex.addItem(addAnswerButton).height(44).marginBottom(40)
            flex.addItem(maxAnswerLabel).display(.none).marginBottom(40)
        }
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = keyboardHeight + 8
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 8
        
        // 포커스된 뷰를 키보드 위 8px로 스크롤
        if let activeView = view.findFirstResponder() {
            let rect = activeView.convert(activeView.bounds, to: scrollView)
            let visibleRect = CGRect(x: rect.origin.x, y: rect.maxY + 8, width: rect.width, height: 1)
            
            UIView.animate(withDuration: duration) {
                self.scrollView.scrollRectToVisible(visibleRect, animated: false)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    // MARK: - Bind
    
    func bind(reactor: MakeVoteReactor) {
        // MARK: - Mode 설정
        switch reactor.currentState.mode {
        case .create:
            navTitleLabel.text = "투표 만들기"
            submitButton.setTitle("게시", for: .normal)
        case .edit:
            navTitleLabel.text = "투표 수정"
            submitButton.setTitle("수정", for: .normal)
        }
        
        // MARK: Action
        
        // 주제 선택
        topicButtons.forEach { button in
            button.rx.tap
                .map { MakeVoteReactor.Action.selectTopic(VoteTopic.allCases[button.tag]) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        // 질문 입력
        questionTextView.rx.text.orEmpty
            .skip(1)
            .do(onNext: { [weak self] text in
                if text.contains("\n") {
                    self?.questionTextView.text = text.replacingOccurrences(of: "\n", with: "")
                    self?.questionTextView.resignFirstResponder()
                    return
                }
                if text.count > 100 {
                    self?.questionTextView.text = String(text.prefix(100))
                }
            })
            .map { $0.replacingOccurrences(of: "\n", with: "") }
            .map { String($0.prefix(100)) }
            .map { MakeVoteReactor.Action.updateQuestion($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 답변 항목 추가
        addAnswerButton.rx.tap
            .map { MakeVoteReactor.Action.addAnswer }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 게시
        submitButton.rx.tap
            .map { MakeVoteReactor.Action.submit }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // MARK: State
        
        // 주제 선택 상태
        reactor.state.map(\.selectedTopic)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] selected in
                self?.updateTopicButtons(selected: selected)
            })
            .disposed(by: disposeBag)
        
        // 질문 글자수
        reactor.state.map(\.question)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                let attributed = NSMutableAttributedString(
                    string: "\(text.count)",
                    attributes: [.foregroundColor: UIColor.grayScale700, .font: UIFont.pretenRegular(12)]
                )
                attributed.append(NSAttributedString(
                    string: "/100",
                    attributes: [.foregroundColor: UIColor.grayScale600, .font: UIFont.pretenRegular(12)]
                ))
                self?.questionCountLabel.attributedText = attributed
                self?.questionCountLabel.flex.markDirty()
                self?.view.setNeedsLayout()
                self?.questionPlaceholder.isHidden = !text.isEmpty
                if self?.questionTextView.text != text {
                    self?.questionTextView.text = text
                }
            })
            .disposed(by: disposeBag)
        
        // 답변 목록 - 개수가 바뀔 때만 rebuild
        reactor.state.map(\.answers.count)
            .distinctUntilChanged()
            .withLatestFrom(reactor.state.map(\.answers))
            .subscribe(onNext: { [weak self] answers in
                self?.updateAnswerViews(answers: answers, canRemove: answers.count > 2)
            })
            .disposed(by: disposeBag)
        
        // 게시 버튼 활성화
        reactor.state.map(\.isValid)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isValid in
                print("[DEBUG] isValid: \(isValid), topic: \(reactor.currentState.selectedTopic != nil), question: \(reactor.currentState.question.count), answers: \(reactor.currentState.answers.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count)")
                self?.submitButton.isEnabled = isValid
                self?.submitButton.setTitleColor(isValid ? .mainPurple : .grayScale400, for: .normal)
            })
            .disposed(by: disposeBag)
        
        // 추가 버튼 숨김
        reactor.state.map(\.canAddAnswer)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] canAdd in
                self?.addAnswerButton.flex.display(canAdd ? .flex : .none)
                self?.maxAnswerLabel.flex.display(canAdd ? .none : .flex)
                self?.contentContainer.flex.layout(mode: .adjustHeight)
                self?.scrollView.contentSize = self?.contentContainer.frame.size ?? .zero
            })
            .disposed(by: disposeBag)
        
        // 완료
        reactor.state.map(\.isCompleted)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Updates
    
    private func updateTopicButtons(selected: VoteTopic?) {
        topicButtons.enumerated().forEach { index, button in
            let topic = VoteTopic.allCases[index]
            let isSelected = topic == selected
            button.backgroundColor = isSelected ? .lightPurple : .white
            button.setTitleColor(isSelected ? .mainPurple : .grayScale700, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = isSelected ? UIColor.mainPurple.cgColor : UIColor.grayScale200.cgColor
        }
    }
    
    
    private func updateAnswerViews(answers: [String], canRemove: Bool) {
        answerContainer.subviews.forEach { $0.removeFromSuperview() }
        answerContainer.flex.define { flex in
            answers.enumerated().forEach { index, text in
                let isPlaceholder = text.isEmpty
                flex.addItem().marginBottom(8).define { wrapper in
                    let containerView = UIView().then {
                        $0.backgroundColor = .white
                        $0.layer.cornerRadius = 8
                        $0.layer.borderWidth = 1
                        $0.layer.borderColor = UIColor.grayScale200.cgColor
                    }
                    
                    let textView = UITextView().then {
                        $0.font = .pretenMedium(15)
                        $0.textColor = isPlaceholder ? .grayScale400 : .grayScale900
                        $0.backgroundColor = .clear
                        $0.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 40)
                        $0.textContainer.lineFragmentPadding = 0
                        $0.isScrollEnabled = false
                        $0.returnKeyType = .done
                        $0.text = isPlaceholder ? "답변을 입력해주세요" : text
                        $0.tag = index
                    }
                    
                    // 아이콘 버튼 1개 - 포커스에 따라 역할 변경
                    let actionButton = UIButton(type: .system).then {
                        $0.tintColor = .grayScale400
                        if canRemove {
                            $0.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
                            $0.isHidden = false
                        } else {
                            $0.isHidden = true
                        }
                    }
                    
                    var isFocused = false
                    
                    containerView.addSubview(textView)
                    containerView.addSubview(actionButton)
                    
                    textView.translatesAutoresizingMaskIntoConstraints = false
                    actionButton.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        textView.topAnchor.constraint(equalTo: containerView.topAnchor),
                        textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                        textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                        textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                        
                        actionButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                        actionButton.widthAnchor.constraint(equalToConstant: 20),
                        actionButton.heightAnchor.constraint(equalToConstant: 20),
                    ])
                    
                    // 포커스 시: 클리어(x) 아이콘
                    textView.rx.didBeginEditing
                        .subscribe(onNext: { [weak textView, weak actionButton, weak containerView] in
                            guard let tv = textView else { return }
                            isFocused = true
                            if tv.text == "답변을 입력해주세요" && tv.textColor == .grayScale400 {
                                tv.text = ""
                                tv.textColor = .grayScale900
                            }
                            containerView?.layer.borderColor = UIColor.mainPurple.cgColor
                            actionButton?.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                            actionButton?.tintColor = .grayScale300
                            actionButton?.isHidden = tv.text.isEmpty
                        })
                        .disposed(by: disposeBag)
                    
                    // 포커스 해제: 항목삭제(−) 아이콘 복원
                    textView.rx.didEndEditing
                        .subscribe(onNext: { [weak textView, weak actionButton, weak containerView] in
                            guard let tv = textView else { return }
                            isFocused = false
                            if tv.text.isEmpty {
                                tv.text = "답변을 입력해주세요"
                                tv.textColor = .grayScale400
                            }
                            containerView?.layer.borderColor = UIColor.grayScale200.cgColor
                            if canRemove {
                                actionButton?.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
                                actionButton?.tintColor = .grayScale400
                                actionButton?.isHidden = false
                            } else {
                                actionButton?.isHidden = true
                            }
                        })
                        .disposed(by: disposeBag)
                    
                    // 텍스트 변경
                    textView.rx.text.orEmpty
                        .skip(1)
                        .filter { $0 != "답변을 입력해주세요" }
                        .subscribe(onNext: { [weak self, weak actionButton, weak textView, weak containerView] text in
                            // 줄바꿈 → 키보드 내리기
                            if text.contains("\n"), let tv = textView {
                                tv.text = text.replacingOccurrences(of: "\n", with: "")
                                tv.resignFirstResponder()
                                return
                            }
                            // 21자 제한
                            if text.count > 21, let tv = textView {
                                tv.text = String(text.prefix(21))
                                return
                            }
                            if isFocused {
                                actionButton?.isHidden = text.isEmpty
                            }
                            self?.reactor?.action.onNext(.updateAnswer(index: index, text: text))
                            // 높이 갱신
                            if let tv = textView, let container = containerView {
                                let size = tv.sizeThatFits(CGSize(width: tv.frame.width, height: .greatestFiniteMagnitude))
                                let newHeight = max(56, size.height)
                                container.flex.height(newHeight)
                                container.flex.markDirty()
                            }
                            self?.answerContainer.flex.markDirty()
                            self?.contentContainer.flex.layout(mode: .adjustHeight)
                            self?.scrollView.contentSize = self?.contentContainer.frame.size ?? .zero
                        })
                        .disposed(by: disposeBag)
                    
                    // 버튼 탭 - 포커스 상태에 따라 분기
                    actionButton.rx.tap
                        .subscribe(onNext: { [weak self, weak textView, weak actionButton] in
                            if textView?.isFirstResponder == true {
                                // 텍스트 클리어
                                textView?.text = ""
                                actionButton?.isHidden = true
                                self?.reactor?.action.onNext(.updateAnswer(index: index, text: ""))
                            } else {
                                // 항목 삭제
                                self?.reactor?.action.onNext(.removeAnswer(index: index))
                            }
                        })
                        .disposed(by: disposeBag)
                    
                    wrapper.addItem(containerView).grow(1).minHeight(56)
                }
            }
        }
        answerContainer.flex.markDirty()
        view.setNeedsLayout()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MakeVoteViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}

