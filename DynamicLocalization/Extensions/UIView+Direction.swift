//
//  UIView+Direction.swift
//  DynamicLocalization
//
//  Created by Ashfaq Shaikh on 09/02/22.
//

import UIKit

extension UIView {
    ///
    /// Change the direction of the view depeneding in the language, there is no return value for this variable.
    ///
    /// The expectid values:
    ///
    /// -`fixed`: if the view must not change the direction depending on the language.
    ///
    /// -`leftToRight`: if the view must change the direction depending on the language
    /// and the view is left to right view.
    ///
    /// -`rightToLeft`: if the view must change the direction depending on the language
    /// and the view is right to left view.
    ///
    var direction: ViewDirection {
        get {
            fatalError("""
                 There is no value return from this variable,
                 this variable used to change the view direction depending on the langauge
                 """)
        }
        set {
            switch newValue {
            case .fixed:
                break
            case .leftToRight where LanguageManager.shared.isRightToLeft:
                transform = CGAffineTransform(scaleX: -1, y: 1)
            case .rightToLeft where !LanguageManager.shared.isRightToLeft:
                transform = CGAffineTransform(scaleX: -1, y: 1)
            default:
                break
            }
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let roundedLayer = CAShapeLayer()
        roundedLayer.path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath
        layer.mask = roundedLayer
    }
    
    func fadeTo(
        _ alpha: CGFloat,
        duration: TimeInterval = 0.3,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil) {
            
            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: .curveEaseInOut,
                animations: {
                    self.alpha = alpha
                },
                completion: nil
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                completion?()
            }
        }
    
    func fadeIn(duration: TimeInterval = 0.3, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        fadeTo(1, duration: duration, delay: delay, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 0.3, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        fadeTo(0, duration: duration, delay: delay, completion: completion)
    }
}

//--------------------------------------------------
// MARK: - UIViewController
//--------------------------------------------------
public extension UIViewController {
    func presentBottomSheet(_ bottomSheet: BRQBottomSheetViewController, completion: (() -> Void)?) {
        self.present(bottomSheet, animated: false, completion: completion)
    }
}
