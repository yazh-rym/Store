//
//  InstantController.swift
//  Tryon
//
//  Created by Udayakumar N on 17/08/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Appsee


class InstantController: UIViewController, NVActivityIndicatorViewable {
    
    
    // MARK: - Class variables
    
    @IBOutlet weak var instantCollectionView: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    let model = TryonModel.sharedInstance
    var userImage: UIImage?
    var inventories = [Inventory]()
    var inventoryType: [String] = []
    var inventoryFilter: [[String: [String]]] = []
    var filters: [[String: [String]]] = [
        [CategoryIdentifiers.productType.rawValue:["EYEGLASSES"],CategoryIdentifiers.frameType.rawValue:["FULLRIM"]],
        [CategoryIdentifiers.productType.rawValue:["EYEGLASSES"],CategoryIdentifiers.frameType.rawValue:["HALFRIM"]],
        [CategoryIdentifiers.productType.rawValue:["EYEGLASSES"],CategoryIdentifiers.frameType.rawValue:["RIMLESS"]],
        [CategoryIdentifiers.productType.rawValue:["SUNGLASSES"]]
    ]
    var user: User? {
        didSet {
            self.userImage = model.image(withIdentifier: "frontFace", in: "jpg")
            
            if self.inventories.count > 0 {
                //Already inventories are obtained.
                if (self.instantCollectionView) != nil {
                    self.instantCollectionView.reloadData()
                }
            } else {
                if (self.instantCollectionView) != nil {
                    getInventoryInProgress()
                    getInventory()
                }
            }
        }
    }
    
    let inProgressText = "Loading..."
    let noDataText = "Loading..."
    
    
    // MARK: - Init functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instantCollectionView.allowsMultipleSelection = false
        
        getInventoryInProgress()
        getInventory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        instantCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Appsee.startScreen("Instant")
        
        super.viewDidAppear(animated)
    }
    
    
    // MARK: - Get Data
    
    func getInventory() {
        for filter in filters {
            InventoryFilterHelper().filterInventory(allFilters: filter, rangeFilters: nil, page: 1, completionHandler: { [filter = filter] (dataArray, page, inventoryCount, error) -> () in
                if let _ = error {
                    self.getInventoryFailed()
                    //TODO: Handle this
                    
                } else {
                    if dataArray.count > 0 {
                        for data in dataArray {
                            self.inventories.append(data)
                            if let type = filter[CategoryIdentifiers.frameType.rawValue]?.first {
                                self.inventoryType.append(type)
                            } else if let type = filter[CategoryIdentifiers.productType.rawValue]?.first {
                                self.inventoryType.append(type)
                            }
                            self.inventoryFilter.append(filter)
                            break
                        }
                        
                        self.getInventorySuccess()
                        self.instantCollectionView.reloadData()
                    } else {
                        log.info("No inventory found for filter")
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
        self.stopAnimating()
        self.noDataLabel.isHidden = true
    }
    
    func getInventoryFailed() {
        self.stopAnimating()
        self.noDataLabel.isHidden = false
        self.noDataLabel.text = noDataText
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewAllController = segue.destination as? ViewAllController {
            viewAllController.user = self.user

            if let indexPaths = instantCollectionView.indexPathsForSelectedItems {
                if let selectedRow = indexPaths.first?.row {
                    let filter = inventoryFilter[selectedRow]
                    viewAllController.allFilters = filter
                }
            }
        }
    }
}


// MARK: - CollectionView delegates

extension InstantController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inventories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = instantCollectionView.dequeueReusableCell(withReuseIdentifier: "instantCell", for: indexPath) as! InstantCell
        let inventory = inventories[indexPath.row]
        let type = inventoryType[indexPath.row]
        
        cell.lookzId = inventory.id
        cell.userImageView.image = userImage
        cell.typeLabel.text = type.lowercased().capitalizingFirstLetter()
        
        //getUser2DRender(forLookzId: inventory.id!, frameNumber: (self.user?.frontFrameIndex)!, atCell: cell)

        return cell
    }

    
    // MARK: - Render functions
    
    func getUser2DRender(forFrame frame: InventoryFrame, frameNumber: Int, atCell cell: InstantCell) {
        if let img = self.model.imageFromCache(withIdentifier: String(frame.id) + "-2D-" + String(frameNumber)) {
            if let cellLookzId = cell.lookzId {
                if cellLookzId == String(frame.id) {
                    //Image already available in cache
                    cell.glassImageView.image = img
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
                            if let cellLookzId = cell.lookzId {
                                if cellLookzId == String(frame.id) {
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
                                if let cellLookzId = cell.lookzId {
                                    if cellLookzId == String(frame.id) {
                                        //Error in downloading the glass image
                                        cell.glassImageView.image = nil
                                        self.getUser2DRenderFailed(atCell: cell)
                                    }
                                }
                            }
                            
                            log.error("Instant - User Render 2D - Error in downloading image from \(glassUrl)")
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        if let cellLookzId = cell.lookzId {
                            if cellLookzId == String(frame.id) {
                                //Error in getting Glass Center json
                                cell.glassImageView.image = nil
                                self.getUser2DRenderFailed(atCell: cell)
                            }
                        }
                    }
                    
                    log.error("Instant - User Render 2D - Error in getting glass center json from \(jsonUrl)")
                }
            })
        }
    }
    
    func getUser2DRenderInProgress(atCell cell: InstantCell) {
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.isHidden = false
    }
    
    func getUser2DRenderSuccess(atCell cell: InstantCell) {
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.isHidden = true
    }
    
    func getUser2DRenderFailed(atCell cell: InstantCell) {
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.isHidden = true
        cell.failedIndicatorImageView.isHidden = false
    }
}
