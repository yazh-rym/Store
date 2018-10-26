//
//  ModelSelectionCell.swift
//  Tryon
//
//  Created by Udayakumar N on 13/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit

class ModelSelectionCell: UICollectionViewCell {
        
    @IBOutlet weak var modelAvatarImgView: UIImageView!
    @IBOutlet weak var modelTypeLabel: UILabel!
    
    let imageCornerRadius:CGFloat = 20.0
    let imageBorderWidth:CGFloat = 1.0
 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        modelAvatarImgView.layer.cornerRadius = imageCornerRadius
        modelAvatarImgView.layer.borderWidth = imageBorderWidth
        modelAvatarImgView.layer.borderColor = UIColor.modelImageBorderColor.cgColor
        modelAvatarImgView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        modelAvatarImgView.image = nil
    }
}
