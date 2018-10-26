//
//  FilterInventoryCell.swift
//  Tryon
//
//  Created by Udayakumar N on 13/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import FaveButton

class FilterInventoryCell: UITableViewCell {
    
    // MARK: - Class variables
    
    let inventoryCornerRadius: CGFloat = 10.0
    let inventoryBorderWidth: CGFloat = 1.0
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var inventoryImage: UIImageView!
    @IBOutlet weak var inventoryName: UILabel!
    @IBOutlet weak var inventorySubName: UILabel!
    @IBOutlet weak var inventoryLikeButton: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.borderView.layer.cornerRadius = inventoryCornerRadius
        self.borderView.layer.borderWidth = inventoryBorderWidth
        self.borderView.layer.borderColor = UIColor.filterImageBorderColor.cgColor
    }
    
    override func prepareForReuse() {
        inventoryImage.image = nil
        
        super.prepareForReuse()
    }
}
