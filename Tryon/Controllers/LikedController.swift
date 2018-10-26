//
//  LikedController.swift
//  Tryon
//
//  Created by Udayakumar N on 17/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Appsee


class LikedController: UIViewController, Tryon3DDelegate, LikeDelegate {
    
    
    // MARK: - Class variables
    
    @IBOutlet weak var likedCollectionView: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
    
    let tryon3D = Tryon3D.sharedInstance
    let model = TryonModel.sharedInstance
    var operationQueue: OperationQueue = OperationQueue()
    
    
    // MARK: - Init functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* TODO: Fix this
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        self.likedCollectionView.addGestureRecognizer(longPressGesture)
        */
        
        operationQueue.qualityOfService = .background
        operationQueue.maxConcurrentOperationCount = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        operationQueue.cancelAllOperations()
        self.likedCollectionView.reloadData()
        
        tryon3D.tryon3DDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Appsee.startScreen("Shortlist")
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tryon3D.tryon3DDelegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        //TODO: Handle this
        log.error("MEMORY WARNING in LikedController")
    }
    
    
    // MARK: - Tryon3DDelegate functions
    
    func tryon3DDownloadDidComplete(forFrameId frameId: Int, withSuccessStatus status: Bool) {
        if let index = tryon3D.getUserLiked().index(where: { $0.frame.id == frameId }) {
            self.likedCollectionView.performBatchUpdates({
                let indexPath = IndexPath(row: index, section: 0)
                self.likedCollectionView.reloadItems(at: [indexPath])
            }, completion: nil)
        }
    }
    
    func likeButtonDidTap(forUserLiked userLiked: UserLiked) {
        if tryon3D.isUserLiked(frameId: userLiked.frame.id) {
            //Already Liked. So Dislike it
            var i = 0
            for liked in tryon3D.getUserLiked() {
                if userLiked.frame.id == liked.frame.id {
                    break
                } else {
                    i = i + 1
                }
            }
            let indexPath = IndexPath(row: i, section: 0)
            
            self.likedCollectionView.performBatchUpdates({
                self.tryon3D.removeUserLiked(userLiked: userLiked)
                self.likedCollectionView.deleteItems(at: [indexPath])
            }, completion: nil)
        }
        
        let likedCount = tryon3D.countUserLiked()
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.updateLikedBadgeCount(withCount: likedCount)
        }
    }
    
    func imageDidTap(inCell cell: LikedCell) {
        guard let productDetailsController = UIStoryboard(name:"MainApp", bundle:nil).instantiateViewController(withIdentifier: "productDetails") as? ProductDetailsController else {
            log.error("Could not instantiate view controller")
            return
        }
        
        if let indexPath = self.likedCollectionView.indexPath(for: cell as UICollectionViewCell) {
            productDetailsController.user = tryon3D.user
            productDetailsController.frame = tryon3D.getUserLiked()[indexPath.row].frame
            self.navigationController?.pushViewController(productDetailsController, animated:true)
        }
    }
    
    
    // MARK: - Prepare Segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? LikedCell, let indexPath = likedCollectionView.indexPath(for: cell) {
            let productDetailsController = segue.destination as! ProductDetailsController
            productDetailsController.user = tryon3D.user
            productDetailsController.frame = tryon3D.getUserLiked()[indexPath.row].frame
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let cell = sender as? LikedCell {
            if cell.userLiked?.render3D.status == .isFailed {
                return false
            }
        }
        
        return true
    }
}


// MARK: - CollectionView functions

extension LikedController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = tryon3D.getUserLiked().count
        
        if count == 0 {
            self.noDataLabel.isHidden = false
        } else {
            self.noDataLabel.isHidden = true
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = likedCollectionView.dequeueReusableCell(withReuseIdentifier: "likedCell", for: indexPath) as! LikedCell
        let userLiked = tryon3D.getUserLiked()[indexPath.row]
        
        cell.placeHolderImageView.image = model.image(withIdentifier: "frontFace-thumbnail", in: "jpg")
        
        let frame = userLiked.frame
        
        cell.likeDelegate = self
        cell.userLiked = userLiked
        
        if userLiked.render3D.status == Render3DStatus.isCompleted {
            //Since the image order is reversed, reversing the frontFrameIndex
            let totalIndexNumber = (tryon3D.user?.frameNumbers?.count)! - 1
            let reversedFrontFrameIndex = totalIndexNumber - (tryon3D.user?.frontFrameIndex)!
            
            //Add User with Glass images
            let blockOperation: BlockOperation = BlockOperation.init(
                block: {
                    var imageIdentifiers: [String] = []
                    for frameNumber in (self.tryon3D.user?.frameNumbers)! {
                        imageIdentifiers.append("\(userLiked.frame.id)-\(frameNumber)")
                    }
                    cell.addImages(withIdentifiers: imageIdentifiers, scrollTo: reversedFrontFrameIndex)

                    //TODO: Is this required?
//                    DispatchQueue.main.async {
//                        cell.scrollToFace(withDelay: 0.0)
//                    }
            })
            blockOperation.queuePriority = .normal
            self.operationQueue.addOperation(blockOperation)
            
        } else if userLiked.render3D.status == Render3DStatus.isFailed {
            updateUIForTryon3DFailed(forCell: cell)
            
        } else {
            updateUIForTryon3DStillLoading(forCell: cell)
            
        }

        if let thumbNailImageUrl = frame.thumbNailImageUrl {
            if thumbNailImageUrl != "" {
                cell.inventoryImgView.af_setImage(withURL: URL(string: thumbNailImageUrl)!)
            }
        }
        
        cell.likeAnimationButton.isSelected = true
        
        cell.inventoryHeaderLabel.text = frame.productName?.lowercased().capitalizingFirstLetter()
        cell.inventoryItem1Label.text = frame.frameMaterial?.name.lowercased().capitalizingFirstLetter()
//        if let price = frame.price {
//            cell.inventoryItem2Label.text = "₹" + String(price)
//        }
        if let size = frame.size {
            if let letter = size.lowercased().capitalizingFirstLetter().characters.first {
                cell.sizeLabel.text = String(letter)
            }
        }
        
        return cell
    }
    
    func updateUIForTryon3DStillLoading(forCell cell: LikedCell) {
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.isHidden = false
        cell.imageScrollHandlerView.isUserInteractionEnabled = false
        cell.activityIndicatorBackgroundView.isHidden = false
        cell.failedIndicatorImageView.isHidden = true
        cell.isUserInteractionEnabled = false
    }
    
    func updateUIForTryon3DCompleted(forCell cell: LikedCell) {
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.isHidden = true
        cell.imageScrollHandlerView.isUserInteractionEnabled = true
        cell.activityIndicatorBackgroundView.isHidden = true
        cell.failedIndicatorImageView.isHidden = true
        cell.isUserInteractionEnabled = true
    }
    
    func updateUIForTryon3DFailed(forCell cell: LikedCell) {
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.isHidden = true
        cell.imageScrollHandlerView.isUserInteractionEnabled = false
        cell.activityIndicatorBackgroundView.isHidden = false
        cell.failedIndicatorImageView.isHidden = false
        cell.isUserInteractionEnabled = true
    }
    
    
    // MARK: - Reorder functions
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        //Allow Reorder only when the user liked count is more than 1
        if tryon3D.countUserLiked() > 1 {
            switch(gesture.state) {
                
            case UIGestureRecognizerState.began:
                guard let selectedIndexPath = self.likedCollectionView.indexPathForItem(at: gesture.location(in: self.likedCollectionView)) else {
                    break
                }
                likedCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
                
            case UIGestureRecognizerState.changed:
                likedCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
                
            case UIGestureRecognizerState.ended:
                likedCollectionView.endInteractiveMovement()
                
            default:
                likedCollectionView.cancelInteractiveMovement()
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tryon3D.reorderUserLiked(from: sourceIndexPath.item, to: destinationIndexPath.item)
        
        operationQueue.cancelAllOperations()
        likedCollectionView.reloadData()
    }
}
