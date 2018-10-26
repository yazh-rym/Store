//
//  ModelSelectionController.swift
//  Tryon
//
//  Created by Udayakumar N on 13/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import NVActivityIndicatorView
import Appsee


class ModelSelectionController: UIViewController, NVActivityIndicatorViewable, SomethingWentWrongDelegate, CollectDataDelegate {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    var selectedModelAvatar: ModelAvatar?
    let noModelText = "No model found"
    let inProgressText = "Loading..."
    var modelAvatars = [ModelAvatar]()
    
    @IBOutlet weak var modelAvatarCollectionView: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBAction func backButtonTapped(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Appsee.startScreen("ModelSelection")
        
        super.viewDidAppear(animated)
    }
    
    // MARK: - Get Data
    func getModel() {
        getModelInProgress()
        
        ModelAvatarHelper().getModelAvatar(completionHandler: { (dataArray, error) -> () in
            if let error = error {
                self.getModelFailed(withError: error)
                self.modelAvatars = []
            } else {
                self.getModelCompleted()
                self.modelAvatars = dataArray
            }
            
            if self.modelAvatars.count == 0 {
                self.noDataLabel.isHidden = false
                self.noDataLabel.text = self.noModelText
            } else {
                self.noDataLabel.isHidden = true
                
                //Reload data
                self.modelAvatarCollectionView.reloadData()
            }
        })
    }
    
    func getModelInProgress() {
        startAnimating(loaderConfig().size, message: loaderConfig().message, type: loaderConfig().type)
        self.noDataLabel.text = self.inProgressText
    }
    
    func getModelFailed(withError error: NSError) {
        self.stopAnimating()
        log.error(error)
        self.showSomethingWentWrongScreen(withMessage: error.localizedDescription)
    }
    
    func getModelCompleted() {
        log.info("Model Avatar load - Completed")
        self.stopAnimating()
    }
    
    func tryAgainDidTap() {
        getModel()
    }
}


// MARK: - CollectionView functions
extension ModelSelectionController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.modelAvatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = modelAvatarCollectionView.dequeueReusableCell(withReuseIdentifier: "modelCell", for: indexPath) as! ModelSelectionCell
        
        let imgUrl = modelAvatars[indexPath.row].frontFaceImgUrl
        if imgUrl != "" {
            cell.modelAvatarImgView.af_setImage(withURL: URL(string: imgUrl)!)
        }
        cell.modelTypeLabel.text = modelAvatars[indexPath.row].modelName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedModelAvatar = modelAvatars[indexPath.row]
        displayCollectDataScreen()
    }
    
    func displayCollectDataScreen() {
        if model.customer == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let collectDataVC = storyboard.instantiateViewController(withIdentifier: "collectData") as! CollectDataController
            collectDataVC.customerVideoType = "M"
            collectDataVC.collectDataDelegate = self
            
            collectDataVC.modalTransitionStyle = .coverVertical
            self.present(collectDataVC, animated: true, completion: nil)
        } else {
            displayShopScreen(withIsReadyForCustomerDetailsUpload: false)
        }
    }
    
    func collectDataSubmitDidTap() {
        displayShopScreen(withIsReadyForCustomerDetailsUpload: true)
    }
    
    func collectDataSkipDidTap() {
        displayShopScreen(withIsReadyForCustomerDetailsUpload: false)
    }
    
    func displayShopScreen(withIsReadyForCustomerDetailsUpload isReadyForCustomerDetailsUpload: Bool) {
        
        ModelAvatarHelper().getModelJson(jsonUrl: (selectedModelAvatar?.jsonUrl)!) { (processVideoResult, error) in
            if let error = error {
                log.error("Get Model Json - Failed with error - \(error)")
                self.showSomethingWentWrongScreen(withMessage: error.localizedDescription)
                
            } else {

                let responseDict = processVideoResult?.value(forKey: "Data") as! NSDictionary?
                
                let yprValues = responseDict?.value(forKey: "YPR") as! [String]?
                
                var sellionPoints: [CGPoint] = []
                let sellionPointsArray = responseDict?.value(forKey: "SellionPoints") as! [[Int]]?
                for sellionPoint in sellionPointsArray! {
                    let point = CGPoint(x: sellionPoint[0], y: sellionPoint[1])
                    sellionPoints.append(point)
                }
                
                let frameNumbers = responseDict?.value(forKey: "FramesList") as! [Int]?
                let frontFrameIndex = responseDict?.value(forKey: "FrontFrameIndex") as! Int?
                let eyeToEyeDistance = responseDict?.value(forKey: "EyeToEyeDistance") as! Double?
                let eyeFrameScaleFactor = responseDict?.value(forKey: "EyeFrameScaleFactor") as! Double?
                let serverFaceSizeArray = responseDict?.value(forKey: "Size") as! [Int]?
                let serverFaceSize = CGSize(width: (serverFaceSizeArray?[0])!, height: (serverFaceSizeArray?[1])!)
                let glassUrl = responseDict?.value(forKey: "GlassPath") as! String?
                let jsonUrl = responseDict?.value(forKey: "JsonPath") as! String?
                
                let tabBarController = self.tabBarController as! MainTabBarController
                tabBarController.enableTabBarItem(item: TabBarList.shop.rawValue)
//                tabBarController.enableTabBarItem(item: TabBarList.instant.rawValue)
                tabBarController.enableTabBarItem(item: TabBarList.profile.rawValue)
                tabBarController.selectedIndex = TabBarList.shop.rawValue
                
                //Remove old files
                FileHelper().removeAllFilesFromCache()
                self.model.imageCache.removeAllImages()
                
                self.model.appVideoUrl = URL(fileURLWithPath: (self.selectedModelAvatar?.appVideoUrl)!)
                let newUser = User(yprValues: yprValues, sellionPoints: sellionPoints, frameNumbers: frameNumbers, frontFrameIndex: frontFrameIndex, eyeToEyeDistance: eyeToEyeDistance, eyeFrameScaleFactor: eyeFrameScaleFactor, serverFaceSize: serverFaceSize, glassUrl: glassUrl, jsonUrl: jsonUrl, userType: UserType.model, serverVideoUrl: self.selectedModelAvatar?.serverVideoUrl, frontFaceImgUrl: self.selectedModelAvatar?.frontFaceImgUrl)
                self.tryon3D.user = newUser
                
                if let shopController = tabBarController.viewControllers?[TabBarList.shop.rawValue] as! ShopController? {
                    shopController.user = newUser
                    shopController.isReadyForCustomerDetailsUpload = isReadyForCustomerDetailsUpload
                }
                
//                if let navController = tabBarController.viewControllers?[TabBarList.instant.rawValue] as! UINavigationController? {
//                    navController.popViewController(animated: false)
//                    if let instantController = navController.topViewController as! InstantController? {
//                        instantController.user = newUser
//                    }
//                }
            }
        }
    }
}
