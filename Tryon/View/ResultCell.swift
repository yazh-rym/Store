//
//  ResultCell.swift
//  Tryon
//
//  Created by Udayakumar N on 09/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

class ResultCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var highlightedLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var tryon3DImageView: UIImageView!
    @IBOutlet weak var cartImageView: UIImageView!
    @IBOutlet weak var tryOnImageView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 6.0
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}
