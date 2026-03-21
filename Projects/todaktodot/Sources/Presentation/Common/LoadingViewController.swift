//
//  LoadingViewController.swift
//  todaktodot
//
//  Created by 임대진 on 3/22/26.
//

import UIKit
import Lottie

final class LoadingViewController: UIViewController {
    weak var coordinator: Coordinator?
    private var gestrueEnabled: Bool?
    
    private let loading = LottieAnimationView(name: "loading").then {
        $0.loopMode = .loop
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        view.backgroundColor = .lightPurple
        
        view.addSubview(loading)
        loading.pin.center().size(160)
        loading.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gestrueEnabled = coordinator?.navigationController.interactivePopGestureRecognizer?.isEnabled
        coordinator?.navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator?.navigationController.interactivePopGestureRecognizer?.isEnabled = gestrueEnabled ?? true
    }
}
