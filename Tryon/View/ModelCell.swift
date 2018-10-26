//
//  ModelCell.swift
//  Tryon
//
//  Created by 1000Lookz on 19/03/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

class ModelCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var tryon3DImageView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width:218 , height:330)

        self.imageView.addCornerRadius(10.0, inCorners: [.topRight, .topLeft])

        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 6.0
        self.clipsToBounds = true
        self.layer.masksToBounds = false
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
