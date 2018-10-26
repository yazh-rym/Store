//
//  ModelTableViewCell.swift
//  Tryon
//
//  Created by 1000Lookz on 09/06/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import ImageSlideshow

class ModelTableViewCell: UITableViewCell {
    @IBOutlet weak var glassImage: UIImageView!
    
    @IBOutlet weak var whiteView: UIView!
    
    @IBOutlet weak var tryOnImageView: UIImageView!
    @IBOutlet weak var GlassesImageView: ImageSlideshow!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    
    @IBOutlet weak var colorLabel: UILabel!
    var frames : InventoryFrame!
    
    var images: [InputSource] = []

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        whiteView.layer.cornerRadius = 10.0
        whiteView.backgroundColor = UIColor.white
        whiteView.layer.shadowColor = UIColor.black.cgColor
        whiteView.layer.shadowOffset = CGSize(width: 4, height: 4)
        whiteView.layer.shadowOpacity = 0.5
        whiteView.layer.shadowRadius = 6.0
        whiteView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func updateCell(infoFrame : InventoryFrame){
        
        frames = infoFrame
        self.images.removeAll()
        
        if let imagePath = frames.imagePath {
            
            let arr = ["PD_Center.jpg", "PD_Right.jpg", "PD_Right45.jpg", "PD_Left.jpg", "PD_Left45.jpg", "PD_Back.jpg"] //Base let arr = ["PD_Center.jpg", "PD_Left.jpg", "PD_Right.jpg", "thumbnail.jpg"]
            DispatchQueue.global(qos: .background).sync {
                for i in 0...3 {
                    let imageName = arr[i]
                    let imageUrlString = imagePath + (frames.uuid) + "/" + imageName
                    self.images.append(KingfisherSource(urlString: imageUrlString)!)
                }
            }
             GlassesImageView.setImageInputs(self.images)
        }
    }
}
