//
//  FeaturedRectImageCell.swift
//  Tryon
//
//  Created by Udayakumar N on 26/10/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit

class FeaturedRectImageCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imageCornerRadius:CGFloat = 20.0
    let imageBorderWidth:CGFloat = 1.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = imageCornerRadius
        self.layer.borderWidth = imageBorderWidth
        self.layer.borderColor = UIColor.filterImageBorderColor.cgColor
        self.clipsToBounds = true
    }
}
