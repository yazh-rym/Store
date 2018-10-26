//
//  FeaturedCell.swift
//  Tryon
//
//  Created by Udayakumar N on 26/10/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit


class FeaturedCell: UITableViewCell {

    @IBOutlet weak var featuredView: iCarousel!
    
    var imgUrls: [String]? = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    func setFeaturedViewDataSourceDelegate<D: iCarouselDataSource & iCarouselDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        featuredView.delegate = dataSourceDelegate
        featuredView.dataSource = dataSourceDelegate
        featuredView.tag = row
        featuredView.type = .linear
        
        featuredView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
