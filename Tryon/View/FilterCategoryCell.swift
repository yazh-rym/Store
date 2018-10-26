//
//  FilterCategoryCell.swift
//  Tryon
//
//  Created by Udayakumar N on 13/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit

class FilterCategoryCell: UITableViewCell {
    
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        categoryImage.image = nil
    }

}
