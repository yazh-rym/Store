//
//  ViewAllCell.swift
//  Tryon
//
//  Created by Udayakumar N on 14/08/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit

class ViewAllCell: UICollectionViewCell {
    
    // MARK: - Class variables
    
    let tryon3D = Tryon3D.sharedInstance
    
    let imageCornerRadius:CGFloat = 20.0
    let imageBorderWidth:CGFloat = 1.0
    let inventoryImageCornerRadius:CGFloat = 5.0
    let inventoryImageBorderWidth:CGFloat = 1.0
    var didUser2DRenderSuccess = false
    var inventoryFrame: InventoryFrame?

    weak var likeDelegate: LikeDelegate?
    
    @IBOutlet weak var placeHolderImageView: UIImageView!
    @IBOutlet weak var glassImageView: UIImageView!
    @IBOutlet weak var inventoryHeaderLabel: UILabel!
    @IBOutlet weak var inventoryItem1Label: UILabel!
    @IBOutlet weak var inventoryItem2Label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var failedIndicatorImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likeButtonDidTap(_ sender: UIButton) {
        if let frameId = self.inventoryFrame?.id {
            if tryon3D.isUserLiked(frameId: frameId) {
                if let image = UIImage(named: "HeartIconDisabled") {
                    self.likeButton.setImage(image, for: .normal)
                }
            } else {
                if let image = UIImage(named: "HeartIcon") {
                    self.likeButton.setImage(image, for: .normal)
                }
            }
        }

        if let frame = self.inventoryFrame {
            self.likeDelegate?.likeButtonDidTap!(forFrame: frame)
        }
    }
    
    
    // MARK: - Init functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeHolderImageView.layer.cornerRadius = imageCornerRadius
        placeHolderImageView.layer.borderWidth = imageBorderWidth
        placeHolderImageView.layer.borderColor = UIColor.viewAllImageBorderColor.cgColor
        placeHolderImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        glassImageView.image = nil
        inventoryFrame = nil
        
        activityIndicator.isHidden = true
        failedIndicatorImageView.isHidden = true
        didUser2DRenderSuccess = false
        
        super.prepareForReuse()
    }
    
}
