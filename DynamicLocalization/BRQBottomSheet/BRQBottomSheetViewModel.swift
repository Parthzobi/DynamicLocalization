//
//  BRQBottomSheetViewModel.swift
//  DynamicLocalization
//
//  Created by Ashfaq Shaikh on 10/02/22.
//

import UIKit

public struct BRQBottomSheetViewModel: BRQBottomSheetPresentable {
   
    public var cornerRadius: CGFloat
    public var animationTransitionDuration: TimeInterval
    public var backgroundColor: UIColor
    
    public init() {
        cornerRadius = 20
        animationTransitionDuration = 0.3
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    public init(cornerRadius: CGFloat,
                animationTransitionDuration: TimeInterval,
                backgroundColor: UIColor ) {
        
        self.cornerRadius = cornerRadius
        self.animationTransitionDuration = animationTransitionDuration
        self.backgroundColor = backgroundColor
    }
}
