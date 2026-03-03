//
//  CountUpAnimator.swift
//  todaktodot
//
//  Created by 임대진 on 3/4/26.
//

import UIKit

final class CountUpAnimator {

    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var duration: Double = 1
    private var targetValue: Double = 0
    private var update: ((Int) -> Void)?

    func start(
        to value: Double,
        duration: Double = 1,
        easing: Easing = .easeInOut,
        update: @escaping (Int) -> Void
    ) {
        displayLink?.invalidate()

        self.targetValue = value
        self.duration = duration
        self.update = { progress in
            update(Int(progress))
        }

        startTime = CACurrentMediaTime()

        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)

        self.easingType = easing
    }

    private var easingType: Easing = .easeInOut

    @objc private func tick() {
        let elapsed = CACurrentMediaTime() - startTime
        let progress = min(elapsed / duration, 1)

        let eased = easingType.apply(to: progress)
        let current = targetValue * eased

        update?(Int(current))

        if progress >= 1 {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
}

enum Easing {
    case easeInOut
    case easeOut
    case linear

    func apply(to t: Double) -> Double {
        switch self {
        case .easeInOut:
            return t < 0.5
                ? 2 * t * t
                : 1 - pow(-2 * t + 2, 2) / 2

        case .easeOut:
            return 1 - pow(1 - t, 3)

        case .linear:
            return t
        }
    }
}
