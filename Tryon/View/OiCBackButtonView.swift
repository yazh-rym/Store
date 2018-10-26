//
//  OiCBackButtonView.swift
//  Tryon
//
//  Created by Udayakumar N on 22/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

class OiCBackButtonView: UIView {
    override func layoutSubviews() {
        self.shadowColor = UIColor.darkGray
        self.shadowOffset = CGSize(width: 4, height: 4)
        self.shadowOpacity = 0.5
        self.shadowRadius = 6.0
    }
}
