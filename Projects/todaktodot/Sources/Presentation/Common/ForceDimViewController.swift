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

class ForceDimViewController: UIViewController {
    let url: URL?
    let maintenanceAlertInfo: MaintenanceAlertInfo?
    
    init(url: URL? = nil, maintenanceAlertInfo: MaintenanceAlertInfo? = nil) {
        self.url = url
        self.maintenanceAlertInfo = maintenanceAlertInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainPurple
        
        if let info = maintenanceAlertInfo {
            showAlert(icon: UIImage(resource: .warning), title: info.title, description: info.message, primaryButtonTitle: "확인") {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            }
        } else {
            showAlert(icon: UIImage(resource: .bell), title: "업데이트가 필요해요", description: "원활한 서비스 이용을 위해\n최신 버전으로 업데이트해 주세요", primaryButtonTitle: "업데이트 하기", primaryButtonAction: { [self] in
                if let url {
                    UIApplication.shared.open(url)
                }
            }, isUpdate: .force)
        }
    }
}
