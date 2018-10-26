//
//  InstantCell.swift
//  Tryon
//
//  Created by Udayakumar N on 17/08/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit

class InstantCell: UICollectionViewCell {
 
    
    // MARK: - Class variables
    
    let imageCornerRadius:CGFloat = 20.0
    let imageBorderWidth:CGFloat = 1.0
    var lookzId: String?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var glassImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var failedIndicatorImageView: UIImageView!
    
    
    // MARK: - Init functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = imageCornerRadius
        userImageView.layer.borderWidth = imageBorderWidth
        userImageView.layer.borderColor = UIColor.instantImageBorderColor.cgColor
        userImageView.clipsToBounds = true
        
        glassImageView.layer.cornerRadius = imageCornerRadius
    }
    
    override func prepareForReuse() {
        glassImageView.image = nil
        lookzId = nil
        
        activityIndicator.isHidden = true
        failedIndicatorImageView.isHidden = true
        
        super.prepareForReuse()
    }
}
