//
//  ShopBannerTableViewCell.swift
//  Tryon
//
//  Created by Udayakumar N on 17/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import ImageSlideshow


protocol CollectionBannerDelegate: NSObjectProtocol {
    func collectionBannerDidTap(currentPage: Int)
    func collectionBannerShootDidTap()
}

class ShopBannerTableViewCell: UITableViewCell {

    let imageSlideshowInterval = 6.0 //secs
    weak var collectionBannerDelegate: CollectionBannerDelegate?
    
    @IBOutlet weak var imageSlideShowView: ImageSlideshow!
    @IBOutlet weak var imageSlideShowViewShadowView: UIView!
    @IBOutlet weak var exploreView: UIView!
    @IBOutlet weak var shootButton: UIButton!
    @IBOutlet weak var modelButton: UIButton!
    @IBOutlet weak var shootLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var exploreHeadingLabel: UILabel!
    @IBAction func shootButtonDidTap(_ sender: UIButton) {
        self.collectionBannerDelegate?.collectionBannerShootDidTap()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.mainBackgroundColor
        self.contentView.backgroundColor = UIColor.mainBackgroundColor
        self.exploreView.backgroundColor = UIColor.primaryLightColor
        self.shootButton.backgroundColor = UIColor.primaryDarkColor
        self.modelButton.backgroundColor = UIColor.primaryLightColor
        self.modelButton.borderColor = UIColor.primaryDarkColor
        self.modelButton.borderWidth = 1.0
        
        self.shootLabel.textColor = UIColor.primaryLightColor
        self.modelLabel.textColor = UIColor.primaryDarkColor
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("EXPLORE", size: 18, color: UIColor.primaryDarkColor)
            .light(" THE LOOK OF YOURS ", size: 18, color: UIColor.primaryDarkColor)
            .bold("VIRTUALLY", size: 18, color: UIColor.primaryDarkColor)
        exploreHeadingLabel.attributedText = formattedString
        
        
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
        
        exploreView.layer.shadowColor = UIColor.lightGray.cgColor
        exploreView.layer.shadowOffset = CGSize(width: 4, height: 4)
        exploreView.layer.shadowOpacity = 0.6
        exploreView.layer.shadowRadius = 6.0
        exploreView.clipsToBounds = false
        exploreView.layer.masksToBounds = false
        exploreView.layer.shouldRasterize = true
        exploreView.layer.rasterizationScale = UIScreen.main.scale
        
        imageSlideShowView.addShadowViews()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        imageSlideShowView.addGestureRecognizer(gestureRecognizer)
    }
    
    func didTap() {
        self.collectionBannerDelegate?.collectionBannerDidTap(currentPage: self.imageSlideShowView.currentPage)
    }
}
