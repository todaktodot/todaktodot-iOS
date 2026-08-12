//
//  VoteRepositoryImpl.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import RxSwift
import NetworkKit
import Alamofire

final class VoteRepositoryImpl: VoteRepository {
    
    private let networkManager: NetworkManager
    
    init(
        networkManager: NetworkManager
    ) {
        self.networkManager = networkManager
    }
    
}
