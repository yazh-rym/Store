//
//  FavouriteCell.swift
//  Tryon
//
//  Created by Yazh Mozhi on 12/08/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

class FavouriteCell: UITableViewCell {

    @IBOutlet weak var addCart: UIView!
    @IBOutlet weak var favourite: UIView!
    @IBOutlet weak var share: UIView!
    @IBOutlet weak var contentVw: UIView!
    
    @IBOutlet weak var cartBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var modelImg: UIImageView!
    @IBOutlet weak var frameImg: UIImageView!
    
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var modelFrame: UILabel!
    @IBOutlet weak var rimType: UILabel!
    @IBOutlet weak var frameType: UILabel!
    @IBOutlet weak var frameSize: UILabel!
    @IBOutlet weak var frameColor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        
        //Configure UI
        contentVw.layer.shadowColor = UIColor.lightGray.cgColor
        contentVw.layer.shadowOffset = CGSize(width: 5, height: 5)
        contentVw.layer.shadowOpacity = 0.5
        contentVw.layer.shadowRadius = 6.0
        contentVw.cornerRadius = 10.0
        contentVw.clipsToBounds = false
        contentVw.layer.masksToBounds = false
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale

        addCart.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        addCart.clipsToBounds = true
        addCart.masksToBounds = true
        
        favourite.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        favourite.clipsToBounds = true
        favourite.masksToBounds = true
        
        share.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        share.clipsToBounds = true
        share.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
