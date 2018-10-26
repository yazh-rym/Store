//
//  ViewAllController.swift
//  Tryon
//
//  Created by Udayakumar N on 14/08/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Appsee


class ViewAllController: UIViewController, NVActivityIndicatorViewable {

    
    // MARK: - Class variables
    
    @IBOutlet weak var viewAllCollectionView: UICollectionView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
    
    let model = TryonModel.sharedInstance
    var userImage: UIImage?
    var inventoryFrames = [InventoryFrame]()
    var nextInventoryPageNumber = 1
    var isAllInventoryDataLoaded = false
    var user: User?
    var allFilters: [String: [String]] = [:]
    
    let inProgressText = "Loading..."
    let maxUserLikedCountReachedText = "You have already shortlisted 9 Glasses. Please remove some of them, before short-listing new glasses."
    
    let tryon3D = Tryon3D.sharedInstance
    
    
    // MARK: - Init functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewAllCollectionView.allowsMultipleSelection = false
        
        self.userImage = model.image(withIdentifier: "frontFaceForInstant-thumbnail", in: "jpg")
        getInventoryInProgress()
        getInventory()
        
        headerLabel.text = allFilters.first?.value.first?.capitalizingFirstLetter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewAllCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Appsee.startScreen("InstantViewAll")
        
        super.viewDidAppear(animated)
    }
    
    
    // MARK: - Get Data
    
    func getInventory() {
        if !(isAllInventoryDataLoaded) {
            InventoryFrameHelper().filterInventory(allFilters: self.allFilters, rangeFilters: nil, page: self.nextInventoryPageNumber, completionHandler: {  (dataArray, page, inventoryCount, error) -> () in
                if let _ = error {
                    //TODO: Handle this

                } else {
                    if dataArray.count > 0 {
                        self.nextInventoryPageNumber += 1
                        
                        for data in dataArray {
                            self.inventoryFrames.append(data)
                        }
                        
                        self.getInventorySuccess()
                        self.viewAllCollectionView.reloadData()
                    } else {
                        log.info("All inventory data fetched")
                        self.isAllInventoryDataLoaded = true
                        
                    }
                }
            })
        }
    }
    
    func getInventoryInProgress() {
        startAnimating(loaderConfig().size, message: loaderConfig().message, type: loaderConfig().type)
        self.noDataLabel.text = self.inProgressText
    }
    
    func getInventorySuccess() {
        self.noDataLabel.isHidden = true
        self.stopAnimating()
    }
    
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let cell = sender as? ViewAllCell {
            return cell.didUser2DRenderSuccess
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let productDetailsController = segue.destination as? ProductDetailsController {
            productDetailsController.user = self.user
            
            if let indexPaths = viewAllCollectionView.indexPathsForSelectedItems {
                if let selectedRow = indexPaths.first?.row {
                    productDetailsController.frame = self.inventoryFrames[selectedRow]
                }
            }
            
            productDetailsController.is3DAlreadyRendered = false
        }
    }
}


// MARK: - CollectionView and Like delegates

extension ViewAllController : UICollectionViewDataSource, UICollectionViewDelegate, LikeDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inventoryFrames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = viewAllCollectionView.dequeueReusableCell(withReuseIdentifier: "viewAllCell", for: indexPath) as! ViewAllCell
        let frame = inventoryFrames[indexPath.row]
        
        cell.inventoryFrame = frame
        cell.placeHolderImageView.image = self.userImage
        
        var headerText = frame.productName?.lowercased().capitalizingFirstLetter()
        if let size = frame.size {
            if let letter = size.lowercased().capitalizingFirstLetter().characters.first {
                headerText = headerText! + " - " + String(letter)
            }
        }
        cell.inventoryHeaderLabel.text = headerText
        
        cell.inventoryItem1Label.text = frame.frameMaterial?.name.lowercased().capitalizingFirstLetter()
//        if let price = frame.price {
//            cell.inventoryItem2Label.text = "₹" + String(price)
//        }
        
        //Update for Like button
        cell.likeDelegate = self
        if tryon3D.isUserLiked(frameId: frame.id) {
            if let image = UIImage(named: "HeartIcon") {
                cell.likeButton.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: "HeartIconDisabled") {
                cell.likeButton.setImage(image, for: .normal)
            }
        }
        
        getUser2DRender(forFrame: frame, frameNumber: (self.user?.frontFrameIndexForInstant)!, atCell: cell, inIndexPath: indexPath)
        
        if indexPath.row == (inventoryFrames.count - 9) {
            getInventory()
        }
        
        return cell
    }
    
    func likeButtonDidTap(forFrame frame: InventoryFrame) {
        if tryon3D.isUserLiked(frameId: frame.id) {
            tryon3D.removeUserLiked(frameId: frame.id)
        } else {
            let userLiked = UserLiked(frame: frame)
            let addResult = tryon3D.addUserLiked(userLiked: userLiked)
            if addResult {
                //Do Nothing
            } else {
                self.showAlertMessage(withTitle: "Sorry!", message: maxUserLikedCountReachedText)
                
                //Update UI
                if let index = self.inventoryFrames.index(where: { $0.id == frame.id }) {
                    self.viewAllCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            }
        }
        
        //Update TabBar
        let likedCount = tryon3D.countUserLiked()
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.updateLikedBadgeCount(withCount: likedCount)
        }
    }
    
    
    // MARK: - Render functions
    
    func getUser2DRender(forFrame frame: InventoryFrame, frameNumber: Int, atCell cell: ViewAllCell, inIndexPath indexPath: IndexPath) {
        if let img = self.model.imageFromCache(withIdentifier: String(frame.id) + "-2D-" + String(frameNumber)) {
            //Image already available in cache
            if let cellLookzId = cell.inventoryFrame?.id {
                if cellLookzId == frame.id {
                    cell.glassImageView.image = img
                    self.getUser2DRenderSuccess(atCell: cell)
                }
            }
        } else {
            getUser2DRenderInProgress(atCell: cell)
            
            let yprValue = self.user?.yprValues?[frameNumber]
            let sellionPoint = self.user?.sellionPoints?[frameNumber]
            let glassUrl = (self.user?.glassUrl)! + frame.uuid + "/Images/" + yprValue! + ".png"
            let jsonUrl = (self.user?.jsonUrl)! + frame.uuid + "/jsons/" + yprValue! + ".json"
            let glassImageForScalingUrl = (self.user?.glassUrl)! + frame.uuid + "/Images/0_0_0.png"
            
            UserRenderHelper().getGlassCenterJson(jsonUrl: jsonUrl, frameUuid: frame.uuid, glassImageForScalingUrl: glassImageForScalingUrl, completionHandler: { (glassCenter, glassSizeForScaling, error) in
                if error == nil {
                    
                    UserRenderHelper().createGlassImage(forUser: self.user, glassUrl: glassUrl, glassSizeForScaling: glassSizeForScaling, glassCenter: glassCenter, sellionPoint: sellionPoint, faceSize: self.user?.serverFaceSize, withUserImage: nil, completionHandler: { (glassImage, error) in
                        
                        if error == nil {
                            if let cellLookzId = cell.inventoryFrame?.id {
                                if cellLookzId == frame.id {
                                    //Update the glass
                                    cell.glassImageView.image = glassImage
                                    self.getUser2DRenderSuccess(atCell: cell)
                                }
                            }
                            
                            DispatchQueue.global(qos: .background).async {
                                self.model.addToCache(glassImage!, withIdentifier: String(frame.id) + "-2D-" + String(frameNumber))
                            }
                        } else {
                            DispatchQueue.main.async {
                                if let cellFrameId = cell.inventoryFrame?.id {
                                    if cellFrameId == frame.id {
                                        //Error in downloading the glass image
                                        cell.glassImageView.image = nil
                                        self.getUser2DRenderFailed(atCell: cell)
                                    }
                                }
                            }
                            
                            log.error("ViewAll - User Render 2D - Error in downloading image from \(glassUrl)")
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        if let cellFrameId = cell.inventoryFrame?.id {
                            if cellFrameId == frame.id {
                                //Error in getting Glass Center json
                                cell.glassImageView.image = nil
                                self.getUser2DRenderFailed(atCell: cell)
                            }
                        }
                    }
                    
                    log.error("ViewAll - User Render 2D - Error in getting glass center json from \(jsonUrl)")
                }
            })
        }
    }
    
    func getUser2DRenderInProgress(atCell cell: ViewAllCell) {
        cell.activityIndicator.startAnimating()
        cell.didUser2DRenderSuccess = false
        cell.activityIndicator.isHidden = false
    }
    
    func getUser2DRenderSuccess(atCell cell: ViewAllCell) {
        cell.didUser2DRenderSuccess = true
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.isHidden = true
    }
    
    func getUser2DRenderFailed(atCell cell: ViewAllCell) {
        cell.activityIndicator.stopAnimating()
        cell.didUser2DRenderSuccess = false
        cell.activityIndicator.isHidden = true
        cell.failedIndicatorImageView.isHidden = false
    }
}
