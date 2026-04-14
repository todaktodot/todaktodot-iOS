//
//  ForceUpdateViewController.swift
//  todaktodot
//
//  Created by 임대진 on 4/12/26.
//

import UIKit
import Then
import FlexLayout
import PinLayout

class ForceUpdateViewController: UIViewController {
    let url: URL?
    
    init(url: URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainPurple
        
        showAlert(icon: UIImage(resource: .bell), title: "업데이트가 필요해요", description: "원활한 서비스 이용을 위해\n최신 버전으로 업데이트해 주세요", primaryButtonTitle: "업데이트 하기", primaryButtonAction: { [self] in
            if let url {
                UIApplication.shared.open(url)
            }
        }, isUpdate: .force)
    }
}
