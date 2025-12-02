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
 showAlert(
     icon: UIImage(systemName: "bell.fill"),
     title: "콕! 상대방에게 알림을 보냈어요\n곧 답변할 거예요",
     primaryButtonTitle: "확인",
     primaryButtonAction: {}
 )
 */


final class AlertViewController: UIViewController {
    
    struct Configuration {
        let icon: UIImage?
        let title: String
        let description: String?
        let primaryButtonTitle: String
        let primaryButtonAction: () -> Void
        let secondaryButtonTitle: String?
        let secondaryButtonAction: (() -> Void)?
    }
    
    private let dimmedView = UIView()
    private let alertContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let buttonContainer = UIView()
    private let primaryButton = UIButton()
    private let secondaryButton = UIButton()
    
    private let config: Configuration
    
    init(config: Configuration) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
        
        if let description = config.description {
            descriptionLabel.font = .pretenRegular(16)
            descriptionLabel.textColor = .grayScale900
            descriptionLabel.numberOfLines = 0
            descriptionLabel.textAlignment = .center
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.5
            paragraphStyle.alignment = .center
            descriptionLabel.attributedText = NSAttributedString(
                string: description,
                attributes: [.paragraphStyle: paragraphStyle]
            )
        }
        
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
        if config.description != nil {
            alertContainer.addSubview(descriptionLabel)
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
                flex.addItem(iconImageView).size(48).alignSelf(.center)
                flex.addItem(titleLabel).marginTop(16)
                
                if config.description != nil {
                    flex.addItem(descriptionLabel).marginTop(8)
                }
                
                flex.addItem(buttonContainer).marginTop(24).define { buttonFlex in
                    if config.secondaryButtonTitle != nil {
                        buttonFlex.direction(.row).justifyContent(.spaceBetween).define { rowFlex in
                            let buttonWidth: CGFloat = (335 - 48 - 8) / 2  // (전체 - 패딩 - 간격) / 2
                            rowFlex.addItem(secondaryButton).height(48).width(buttonWidth)
                            rowFlex.addItem(primaryButton).height(48).width(buttonWidth)
                        }
                    } else {
                        buttonFlex.addItem(primaryButton).height(48)
                    }
                }
            }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dimmedView.pin.all()
        
        alertContainer.flex.layout(mode: .adjustHeight)
        alertContainer.pin.center()
    }
    
    @objc private func primaryButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.config.primaryButtonAction()
        }
    }
    
    @objc private func secondaryButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.config.secondaryButtonAction?()
        }
    }
}

// MARK: - UIViewController Extension
extension UIViewController {
    func showAlert(
        icon: UIImage?,
        title: String,
        description: String? = nil,
        primaryButtonTitle: String,
        primaryButtonAction: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        secondaryButtonAction: (() -> Void)? = nil
    ) {
        let config = AlertViewController.Configuration(
            icon: icon,
            title: title,
            description: description,
            primaryButtonTitle: primaryButtonTitle,
            primaryButtonAction: primaryButtonAction,
            secondaryButtonTitle: secondaryButtonTitle,
            secondaryButtonAction: secondaryButtonAction
        )
        let alertVC = AlertViewController(config: config)
        present(alertVC, animated: true)
    }
}
