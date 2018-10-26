//
//  FullViewCollectionViewCell.swift
//  Tryon
//
//  Created by 1000Lookz on 11/06/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

class FullViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var centerView: UIView!
    
    @IBOutlet weak var centerLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }

}
