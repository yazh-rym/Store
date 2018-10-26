//
//  LikedCell.swift
//  Tryon
//
//  Created by Udayakumar N on 17/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import FaveButton

@objc protocol LikeDelegate: NSObjectProtocol {
    @objc optional func likeButtonDidTap(forUserLiked userLiked: UserLiked)
    @objc optional func likeButtonDidTap(forFrame frame: InventoryFrame)
    @objc optional func imageDidTap(inCell cell: LikedCell)
    @objc optional func updateLikeCount()
}

class LikedCell: UICollectionViewCell, UIScrollViewDelegate {
    
    // MARK: - Class variables
    
    let likedImageCornerRadius:CGFloat = 20.0
    let likedImageBorderWidth:CGFloat = 1.0
    let likedInventoryImageCornerRadius:CGFloat = 5.0
    let likedInventoryImageBorderWidth:CGFloat = 1.0
    
    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    
    var numberOfFrames = 0
    var currentDisplayFrame = 0
    weak var likeDelegate: LikeDelegate?
    weak var userLiked: UserLiked?
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageScrollHandlerView: UIScrollView!
    @IBOutlet weak var placeHolderImageView: UIImageView!
    @IBOutlet weak var inventoryImgView: UIImageView!
    @IBOutlet weak var inventoryHeaderLabel: UILabel!
    @IBOutlet weak var inventoryItem1Label: UILabel!
    @IBOutlet weak var inventoryItem2Label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorBackgroundView: UIView!
    @IBOutlet weak var failedIndicatorImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeAnimationButton: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBAction func likeButtonDidTap(_ sender: UIButton) {
        self.likeDelegate?.likeButtonDidTap!(forUserLiked: userLiked!)
        self.likeAnimationButton.isSelected = false
    }
    
    @IBAction func likeAnimationButtonDidTap(_ sender: FaveButton) {
        self.likeDelegate?.likeButtonDidTap!(forUserLiked: userLiked!)
        self.likeAnimationButton.isSelected = false
    }
    
    
    // MARK: - Init functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageScrollView.layer.cornerRadius = likedImageCornerRadius
        imageScrollView.layer.borderWidth = likedImageBorderWidth
        imageScrollView.layer.borderColor = UIColor.likedImageBorderColor.cgColor
        imageScrollView.clipsToBounds = true
        
        placeHolderImageView.layer.cornerRadius = likedImageCornerRadius
        placeHolderImageView.layer.borderWidth = likedImageBorderWidth
        placeHolderImageView.layer.borderColor = UIColor.likedImageBorderColor.cgColor
        placeHolderImageView.clipsToBounds = true
        
        inventoryImgView.layer.cornerRadius = likedInventoryImageCornerRadius
        inventoryImgView.layer.borderWidth = likedInventoryImageBorderWidth
        inventoryImgView.layer.borderColor = UIColor.likedInventoryImageBorderColor.cgColor
        inventoryImgView.clipsToBounds = true
        
        imageScrollView.contentOffset = CGPoint(x: CGFloat(currentDisplayFrame) * imageScrollView.bounds.width, y: 0)
        
        imageScrollHandlerView.delegate = self
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:  #selector(handlePanGesture))
        imageScrollHandlerView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        imageScrollHandlerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        inventoryImgView.image = nil
        
        numberOfFrames = 0
        currentDisplayFrame = 0
        
        removeAllImages()
        
        activityIndicator.isHidden = true
        failedIndicatorImageView.isHidden = true
    }
    
    
    // MARK: - Tryon3D functions
    
    func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.location(in: self.contentView)
            handleGesture(x: translation.x, y: translation.y)
        }
    }
    
    func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        likeDelegate?.imageDidTap!(inCell: self)
    }
    
    func handleGesture(x: CGFloat, y: CGFloat) {
        var x = x
        if y > (imageScrollView.center.y + imageScrollView.bounds.height/2) || y < (imageScrollView.center.y - imageScrollView.bounds.height/2){
            return
        }
        
        x = x - (self.contentView.bounds.width - imageScrollView.bounds.width)/2
        //page going from 1 to numberOfFrames
        var page = Int((x/imageScrollView.bounds.width)*CGFloat(numberOfFrames)) + 1
        if page < 1 {
            page = 1
        }
        if page > numberOfFrames {
            page = numberOfFrames
        }
        
        currentDisplayFrame = page - 1
        imageScrollView.contentOffset = CGPoint(x: CGFloat(currentDisplayFrame)*imageScrollView.bounds.width, y: 0)
    }
    
    func scrollToFace(withDelay delay: Double) {
        var delay = delay
        
        // Scroll to the right end
        for i in stride(from: (tryon3D.user?.frontFrameIndex)!, to: 0, by: -1) {
            delay += 0.08
            scrollToFrame(i: i, withDelay: delay)
        }
        
        // Scroll back to the center
        for i in 0..<((tryon3D.user?.frontFrameIndex)!) {
            delay += 0.08
            scrollToFrame(i: i, withDelay: delay)
        }
        
        // Scroll to exact center
        //scrollToFrame(i: (userLiked?.user?.frontFrameIndex)!, withDelay: delay)
    }
    
    func scrollToFrame(i: Int, withDelay delay: Double) {
        self.currentDisplayFrame = i
        self.imageScrollView.contentOffset = CGPoint(x: CGFloat(self.currentDisplayFrame) * self.imageScrollView.bounds.width, y: 0)
    }
    
    func removeAllImages() {
        log.info("LikedCell - removeAllImages() - Started")
        for view in imageScrollView.subviews {
            if view is UIImageView {
                let imgView = view as! UIImageView
                
                //Glass images
                if imgView.tag > 1 {
                    imgView.image = nil
                }
            }
            view.removeFromSuperview()
        }
        log.info("LikedCell - removeAllImages() - Completed")
    }
    
    func addImages(withImages images: [UIImage], scrollTo frame: Int) {
        log.info("LikedCell - addImages(withImages: , scrollTo: ) - Started")
        numberOfFrames = images.count
        imageScrollView.contentSize = CGSize(width: CGFloat(images.count) * imageScrollView.bounds.width, height: imageScrollView.bounds.height)
        
        imageScrollView.isHidden = true
        
        var i: CGFloat = 0.0
        var counter: Int = 1
        for img in images.reversed() {
            let tempImageView = UIImageView(frame: CGRect(x: i, y: 0, width: self.imageScrollView.bounds.width, height: self.imageScrollView.bounds.height))
            tempImageView.image = img
            tempImageView.tag = 0

            tempImageView.clipsToBounds = true
            tempImageView.contentMode = .scaleAspectFill
            tempImageView.layer.cornerRadius = 5
            tempImageView.layer.masksToBounds = true
            
            DispatchQueue.main.async { [a = counter] in
                self.imageScrollView.addSubview(tempImageView)
                
                if a == images.count {
                    //All images loaded
                    self.scrollToFrame(i: frame, withDelay: 0.0)
                    self.imageScrollView.isHidden = false
                    
                    self.bringSubview(toFront: self.likeAnimationButton)
                }
            }
            
            i += self.imageScrollView.bounds.width
            counter += 1
        }
    }
    
    func addImages(withIdentifiers identifiers: [String], scrollTo frame: Int) {
        log.info("LikedCell - addImages(withIdentifiers: , scrollTo: ) - Started")
        numberOfFrames = identifiers.count
        imageScrollView.contentSize = CGSize(width: CGFloat(identifiers.count) * imageScrollView.bounds.width, height: imageScrollView.bounds.height)
        
        imageScrollView.isHidden = true
        
        var i: CGFloat = 0.0
        var counter: Int = 1
        
        for identifier in identifiers.reversed() {
            let tempImageView = UIImageView(frame: CGRect(x: i, y: 0, width: self.imageScrollView.bounds.width, height: self.imageScrollView.bounds.height))
            
            if let img = self.model.image(withIdentifier: identifier, in: "jpg") {
                tempImageView.image = img
                tempImageView.tag = counter
            } else {
                log.error("Image not found for identifier: \(identifier)")
            }
            
            tempImageView.clipsToBounds = true
            tempImageView.contentMode = .scaleAspectFill
            tempImageView.layer.cornerRadius = 5
            tempImageView.layer.masksToBounds = true
            
            DispatchQueue.main.async { [a = counter] in
                self.imageScrollView.addSubview(tempImageView)
                
                if a == identifiers.count {
                    //All images loaded
                    self.scrollToFrame(i: frame, withDelay: 0.0)
                    self.imageScrollView.isHidden = false
                    
                    self.bringSubview(toFront: self.likeAnimationButton)
                    self.updateUIForTryon3DCompleted()
                }
            }
            
            i += self.imageScrollView.bounds.width
            counter += 1
        }
    }
    
    func updateUIForTryon3DCompleted() {
        self.activityIndicatorBackgroundView.isHidden = true
        self.imageScrollHandlerView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        self.failedIndicatorImageView.isHidden = true
        self.activityIndicator.isHidden = true
    }
}
