//
//  CustomBackViewController.swift
//  todaktodot
//
//  Created by 임대진 on 1/27/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout

protocol CustomBackViewControllerDelegate: AnyObject {
    func navigateBack()
}

class CustomBackViewController: UIViewController {
    weak var delegate: CustomBackViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    private func setup() {
        let backButton = UIBarButtonItem(
            image: UIImage(resource: .back),
            style: .plain,
            target: self,
            action: #selector(backButtonTap)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.titleTextAttributes = [
            .font: UIFont.pretenSemiBold(18),
            .foregroundColor: UIColor.grayScale900
        ]
        
        guard let navigationController = navigationController else { return }
        
        navigationController.navigationBar.isHidden = false
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        
        disableGlassStyle()
    }
    
    @objc private func backButtonTap() {
        delegate?.navigateBack()
    }
}
