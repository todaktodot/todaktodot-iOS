//
//  CustomAlertViewController.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import UIKit
import FlexLayout
import PinLayout

/*
 사용 예시:
 
 // 기본 Alert
 showAlert(
     icon: UIImage(systemName: "bell.fill"),
     title: "콕! 상대방에게 알림을 보냈어요\n곧 답변할 거예요",
     primaryButtonTitle: "확인",
     primaryButtonAction: {}
 )

 // 빨간 텍스트(현재는 아래 한정)
 showAlert(
     icon: UIImage(named: "Warning"),
     title: "답변을 완료하시겠어요?",
     description: "답변을 완료하시면",
     tintedDescription: "더 이상 수정이 불가합니다.",
     primaryButtonTitle: "답변 완료",
     primaryButtonAction: {},
     secondaryButtonTitle: "취소",
     secondaryButtonAction: {}
 )
 */

enum AppUpdateType {
    case force, optional, none
}

final class AlertViewController: UIViewController {
    
    struct Configuration {
        let icon: UIImage?
        let title: String
        let description: String?
        let subDescription: String?
        let tintedDescription: String?
        let primaryButtonTitle: String
        let primaryButtonAction: () -> Void
        let secondaryButtonTitle: String?
        let secondaryButtonAction: (() -> Void)?
        let isUpdateAlert: AppUpdateType?
        let dimColor: UIColor
    }
    
    private let dimmedView = UIView()
    private let alertContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = TDLabel()
    private let descriptionLabel = TDLabel()
    private let subDescriptionLabel = TDLabel()
    private let buttonContainer = UIView()
    private let primaryButton = UIButton()
    private let secondaryButton = UIButton()
    private let skipTodayButton = UIButton(type: .system).then {
        let attributedString = NSAttributedString(
            string: "오늘 하루 다시 보지 않기",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.grayScale600,
                .font: UIFont.pretenRegular(14)
            ]
        )
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    private let config: Configuration
    
    init(config: Configuration) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        if config.isUpdateAlert == .optional {
            skipTodayButton.addTarget(self, action: #selector(skipTodayButtonTapped), for: .touchUpInside)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupInitialState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    private func setupInitialState() {
        dimmedView.alpha = 0
        alertContainer.alpha = 0
        alertContainer.transform = CGAffineTransform(translationX: 0, y: 100)
    }
    
    private func animateIn() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.alertContainer.alpha = 1
            self.alertContainer.transform = .identity
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dimmedView.pin.all()
        
        alertContainer.flex.layout(mode: .adjustHeight)
        alertContainer.pin.center()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        dimmedView.backgroundColor = config.dimColor
        view.addSubview(dimmedView)
        
        alertContainer.backgroundColor = .white
        alertContainer.layer.cornerRadius = 20
        view.addSubview(alertContainer)
        
        iconImageView.image = config.icon
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.text = config.title
        titleLabel.font = .pretenSemiBold(18)
        titleLabel.textColor = .grayScale900
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        let finalAttributedString = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        paragraphStyle.alignment = .center
        
        if let description = config.description {
            let blackAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.pretenRegular(16),
                .foregroundColor: UIColor.grayScale900,
                .paragraphStyle: paragraphStyle
            ]
            finalAttributedString.append(NSAttributedString(string: description, attributes: blackAttributes))
        }
        
        if config.description != nil && config.tintedDescription != nil {
            finalAttributedString.append(NSAttributedString(string: "\n"))
        }
        
        if let tintedText = config.tintedDescription {
            let redAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.pretenSemiBold(16),
                .foregroundColor: TodotColors.System.red,
                .paragraphStyle: paragraphStyle
            ]
            finalAttributedString.append(NSAttributedString(string: tintedText, attributes: redAttributes))
        }
        
        descriptionLabel.attributedText = finalAttributedString
        descriptionLabel.numberOfLines = 0
        
        subDescriptionLabel.text = config.subDescription
        subDescriptionLabel.font = .pretenRegular(14)
        subDescriptionLabel.textColor = .grayScale500
        subDescriptionLabel.numberOfLines = 0
        subDescriptionLabel.textAlignment = .center
        
        primaryButton.setTitle(config.primaryButtonTitle, for: .normal)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.titleLabel?.font = .pretenSemiBold(16)
        primaryButton.backgroundColor = TodotColors.Button.purpleButton1
        primaryButton.layer.cornerRadius = 6
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        
        if let secondaryTitle = config.secondaryButtonTitle {
            secondaryButton.setTitle(secondaryTitle, for: .normal)
            secondaryButton.setTitleColor(.grayScale600, for: .normal)
            secondaryButton.titleLabel?.font = .pretenMedium(16)
            secondaryButton.backgroundColor = .white
            secondaryButton.layer.cornerRadius = 6
            secondaryButton.layer.borderWidth = 1
            secondaryButton.layer.borderColor = UIColor.grayScale200.cgColor
            secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        }
        
        alertContainer.addSubview(iconImageView)
        alertContainer.addSubview(titleLabel)
        
        if config.description != nil || config.tintedDescription != nil {
            alertContainer.addSubview(descriptionLabel)
        }
        
        if config.subDescription != nil {
            alertContainer.addSubview(subDescriptionLabel)
        }
        
        alertContainer.addSubview(buttonContainer)
        buttonContainer.addSubview(primaryButton)
        if config.secondaryButtonTitle != nil {
            buttonContainer.addSubview(secondaryButton)
        }
        
        alertContainer.flex
            .width(335)
            .padding(24)
            .define { flex in
                flex.addItem(iconImageView).size(45).alignSelf(.center)
                flex.addItem(titleLabel).marginTop(16)
                
                if config.description != nil || config.tintedDescription != nil {
                    flex.addItem(descriptionLabel).marginTop(8)
                }

                if config.subDescription != nil {
                    flex.addItem(subDescriptionLabel).marginTop(8)
                }
                
                flex.addItem(buttonContainer).marginTop(24).define { buttonFlex in
                    if config.secondaryButtonTitle != nil {
                        buttonFlex.direction(.row).justifyContent(.spaceBetween).define { rowFlex in
                            let buttonWidth: CGFloat = (335 - 48 - 8) / 2
                            rowFlex.addItem(secondaryButton).height(48).width(buttonWidth)
                            rowFlex.addItem(primaryButton).height(48).width(buttonWidth)
                        }
                    } else {
                        buttonFlex.addItem(primaryButton).height(48)
                    }
                }
                
                if config.isUpdateAlert == .optional {
                    flex.addItem(skipTodayButton)
                        .marginTop(16)
                        .alignSelf(.center)
                }
            }
    }
    
    func setTintedDescription(_ text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        paragraphStyle.alignment = .center
        
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttributes([
            .font: UIFont.pretenRegular(16),
            .foregroundColor: UIColor.grayScale900,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: attributedString.length))
        
        let redRange = (text as NSString).range(of: "더 이상 수정이 불가합니다.")
        if redRange.location != NSNotFound {
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemRed, range: redRange)
        }
        
        descriptionLabel.attributedText = attributedString
    }
    
    @objc private func primaryButtonTapped() {
        if let isUpdate = self.config.isUpdateAlert, isUpdate == .force {
            self.config.primaryButtonAction()
        } else {
            animateOut { [weak self] in
                self?.dismiss(animated: false) {
                    self?.config.primaryButtonAction()
                }
            }
        }
    }
    
    @objc private func secondaryButtonTapped() {
        animateOut { [weak self] in
            self?.dismiss(animated: false) {
                self?.config.secondaryButtonAction?()
            }
        }
    }
    
    @objc private func skipTodayButtonTapped() {
        animateOut { [weak self] in
            self?.dismiss(animated: false) {
                UserdefaultKey.skipUpdateAlertToday = Date()
            }
        }
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.dimmedView.alpha = 0
            self.alertContainer.alpha = 0
            self.alertContainer.transform = CGAffineTransform(translationX: 0, y: 100)
        } completion: { _ in
            completion()
        }
    }
}

// MARK: - UIViewController Extension
extension UIViewController {
    func showAlert(
        icon: UIImage?,
        title: String,
        description: String? = nil,
        subDescription: String? = nil,
        tintedDescription: String? = nil,
        primaryButtonTitle: String,
        primaryButtonAction: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        secondaryButtonAction: (() -> Void)? = nil,
        isUpdate: AppUpdateType? = nil,
        dimColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    ) {
        let config = AlertViewController.Configuration(
            icon: icon,
            title: title,
            description: description,
            subDescription: subDescription,
            tintedDescription: tintedDescription,
            primaryButtonTitle: primaryButtonTitle,
            primaryButtonAction: primaryButtonAction,
            secondaryButtonTitle: secondaryButtonTitle,
            secondaryButtonAction: secondaryButtonAction,
            isUpdateAlert: isUpdate,
            dimColor: dimColor
        )
        
        let alertVC = AlertViewController(config: config)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        if let presentedVC = presentedViewController {
            presentedVC.dismiss(animated: false) { [weak self] in
                self?.present(alertVC, animated: false)
            }
        } else {
            present(alertVC, animated: false)
        }
    }
}
