//
//  BaseViewController.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout

protocol BaseViewControllerDelegate: AnyObject {
    func navigateToMyPage()
}

class BaseViewController: UIViewController {
    weak var delegate: BaseViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMyPageButton()
    }
    
    private func setupMyPageButton() {
        navigationController?.navigationBar.isHidden = false
        
        let logoImageView = UIImageView(image: UIImage(resource: .appLogo))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: 92, height: 32)
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 92 + 20, height: 32))
        logoContainer.addSubview(logoImageView)
        logoImageView.frame.origin.x = 5
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoContainer)
        
        let personImageView = UIImageView(image: UIImage(resource: .person))
        personImageView.contentMode = .scaleAspectFit
        personImageView.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        let personContainer = UIView(frame: CGRect(x: 0, y: 0, width: 18 + 35, height: 18))
        personContainer.addSubview(personImageView)
        personImageView.frame.origin.x = 20
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: personContainer)
        
        personImageView.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myPageButtonTapped))
        personImageView.addGestureRecognizer(tap)
        
        disableGlassStyle()
    }
    
    @objc private func myPageButtonTapped() {
        delegate?.navigateToMyPage()
    }
}
