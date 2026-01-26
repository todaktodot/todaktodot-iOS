//
//  Coordinator +.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//

import UIKit

extension Coordinator {
    func navigateToMyPage() {
        let vc = UIViewController()
        vc.title = "My Page"
        vc.view.backgroundColor = .white
        vc.disableGlassStyle()
        navigationController.pushViewController(vc, animated: true)
    }
}
