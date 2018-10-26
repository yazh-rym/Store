//
//  FeaturedUserWithGlassCell.swift
//  Tryon
//
//  Created by Udayakumar N on 26/10/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit

class FeaturedUserWithGlassCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let imageCornerRadius:CGFloat = 20.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = imageCornerRadius
        imageView.clipsToBounds = true
    }
}
