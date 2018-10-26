//
//  ShopBrandTableViewCell.swift
//  Tryon
//
//  Created by Udayakumar N on 17/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import ImageSlideshow


protocol CollectionBrandDelegate: NSObjectProtocol {
    func collectionBrandDidTap(currentPage: Int)
}

class ShopBrandTableViewCell: UITableViewCell {

    let imageSlideshowInterval = 6.0 //secs
    
    weak var collectionBrandDelegate: CollectionBrandDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageSlideShowView: ImageSlideshow!
    @IBOutlet weak var imageSlideShowViewShadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.mainBackgroundColor
        self.contentView.backgroundColor = UIColor.mainBackgroundColor
        
        imageSlideShowView.pageControlPosition = .insideScrollView
        imageSlideShowView.slideshowInterval = imageSlideshowInterval
        imageSlideShowView.contentScaleMode = .scaleAspectFill
        imageSlideShowView.activityIndicator = DefaultActivityIndicator(style: .white, color: UIColor.primaryDarkColor)
        
        imageSlideShowViewShadowView.layer.shadowColor = UIColor.lightGray.cgColor
        imageSlideShowViewShadowView.layer.shadowOffset = CGSize(width: 4, height: 4)
        imageSlideShowViewShadowView.layer.shadowOpacity = 0.6
        imageSlideShowViewShadowView.layer.shadowRadius = 6.0
        imageSlideShowViewShadowView.clipsToBounds = false
        imageSlideShowViewShadowView.layer.masksToBounds = false
        imageSlideShowViewShadowView.layer.shouldRasterize = true
        imageSlideShowViewShadowView.layer.rasterizationScale = UIScreen.main.scale
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        imageSlideShowView.addGestureRecognizer(gestureRecognizer)
    }
    
    func didTap() {
        self.collectionBrandDelegate?.collectionBrandDidTap(currentPage: self.imageSlideShowView.currentPage)
    }
}
