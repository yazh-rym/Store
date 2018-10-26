//
//  FilterCollectionViewCell.swift
//  Tryon
//
//  Created by Udayakumar N on 08/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import Foundation
import UIKit


class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        selectedView.backgroundColor = UIColor.primaryDarkColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageViewBottomConstraint.constant = 20
        imageView.image = nil
    }
}
