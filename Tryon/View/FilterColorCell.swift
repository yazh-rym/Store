//
//  FilterColorCell.swift
//  Tryon
//
//  Created by Udayakumar N on 06/02/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

class FilterColorCell: UICollectionViewCell {
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cornerRadius = 10.0
        self.borderWidth = 1.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.backgroundColor = UIColor.clear
        selectedImageView.image = nil
    }
}
