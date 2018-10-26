//
//  CustomTabBar.swift
//  Tryon
//
//  Created by Udayakumar N on 01/04/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit


class CustomTabBar: UITabBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.tintColor = UIColor.primaryDarkColor
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeThatFits = super.sizeThatFits(size)
        
        return CGSize(width: sizeThatFits.width, height: 80)
    }
    
    //Added to handle tab bar with Image and Text
    override open var traitCollection: UITraitCollection {
        return UITraitCollection(horizontalSizeClass: .compact)
    }   
}
