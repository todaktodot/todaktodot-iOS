//
//  Error +.swift
//  todaktodot
//
//  Created by 임대진 on 2/20/26.
//

import Foundation
import NetworkKit

extension Error {
    var asCustomAFError: CustomAFError? {
        self as? CustomAFError
    }
}
