//
//  TouchPassthroughView.swift
//  todaktodot
//
//  Created by da-hye0 on 3/23/26.
//

import UIKit

final class TouchPassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit === self ? nil : hit
    }
}
