//
//  AnimationConstants.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

struct AnimationConstants {
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let smooth = Animation.smooth(duration: 0.3)
    static let bouncy = Animation.bouncy(duration: 0.5)
    
    struct Transitions {
        static let slideIn = AnyTransition.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
        static let scale = AnyTransition.scale.combined(with: .opacity)
    }
}
