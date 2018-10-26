//
//  UIView+TryonConfig.swift
//  Tryon
//
//  Created by Udayakumar N on 01/02/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    
    //Add corner radius to required sides
    func addCornerRadius(_ radius: CGFloat, inCorners corners: UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}
