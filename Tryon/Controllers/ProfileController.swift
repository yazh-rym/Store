//
//  ProfileController.swift
//  Tryon
//
//  Created by Udayakumar N on 05/04/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class ProfileController: BaseViewController {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var logoutImageView: UIImageView!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var logoutButtonLabel: UILabel!
    
    @IBAction func cancelButtonDidTap(_ sender: UIButton) {
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.menuTabBarView?.selectIndex(newIndex: TabBarList.shop.rawValue)
        }
    }
    
    @IBAction func logoutButtonDidTap(_ sender: UIButton) {
        self.logout()
    }
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        shadowView.backgroundColor = UIColor.mainBackgroundColor
        logoutView.addCornerRadius(20.0, inCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        logoutView.backgroundColor = UIColor.white
        logoutButtonLabel.addCornerRadius(8.0, inCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        
        logoutLabel.textColor = UIColor.primaryDarkColor
        logoutButtonLabel.textColor = UIColor.primaryDarkColor
        logoutButtonLabel.backgroundColor = UIColor.primaryLightColor
        cancelButton.tintColor = UIColor.primaryDarkColor
        
        shadowView.layer.shadowColor = UIColor.lightShadowColor.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 4, height: 60)
        shadowView.layer.shadowOpacity = 0.6
        shadowView.layer.shadowRadius = 6.0
        shadowView.clipsToBounds = false
        shadowView.layer.masksToBounds = false
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func logout() {
        
        //Remove cache
        let imageDownloader = UIImageView.af_sharedImageDownloader
        imageDownloader.imageCache?.removeAllImages()
        URLCache.shared.removeAllCachedResponses()
        UserDefaults.standard.removeObject(forKey: "logoUrl")
        
        UserDefaults.standard.set(nil, forKey: "IDS")
        
        UserDefaults.standard.set(nil, forKey: "imageKey")
        
        UserDefaults.standard.set(nil, forKey: "UsersKey")
        UserDefaults.standard.set(nil , forKey: "userLookId")
        UserDefaults.standard.set(nil , forKey: "favorites")

        //Remove cache kingfisher
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
        ImageCache.default.cleanExpiredDiskCache()
        
        let cache = KingfisherManager.shared.cache
        // Clear memory cache right away.
        cache.clearMemoryCache()
        
        // Clear disk cache. This is an async operation.
        cache.clearDiskCache()
        
        // Clean expired or size exceeded disk cache. This is an async operation.
        cache.cleanExpiredDiskCache()
        
        //Remove Cache files
        FileHelper().removeAllFilesFromCache()
        model.imageCache.removeAllImages()
        
        //Cleanup Tray
        model.trayInventoryFrames.removeAll()
        
        //Cleanup user details
        model.accessToken.removeAll()
        model.relatedDBUsers.removeAll()
        model.userId = 0
        
        //Clear Tryon Singleton
        self.tryon3D.isUserSelectedByAppUser = false
        
        //Reset TabBar
        if let tabBarController = self.tabBarController as? MainTabBarController {
            if let navController = tabBarController.viewControllers?[TabBarList.shop.rawValue] as? UINavigationController {
                navController.popToRootViewController(animated: false)
            }
            
            if let navController = tabBarController.viewControllers?[TabBarList.searchAndFilter.rawValue] as? UINavigationController {
                navController.popToRootViewController(animated: false)
            }
            
            if let navController = tabBarController.viewControllers?[TabBarList.shoot.rawValue] as? UINavigationController {
                navController.popToRootViewController(animated: false)
            }
            
            if let navController = tabBarController.viewControllers?[TabBarList.tray.rawValue] as? UINavigationController {
                navController.tabBarItem.badgeValue = nil
                navController.popToRootViewController(animated: false)
            }
            
            tabBarController.removeLogoFromWindow()
            tabBarController.removeMenuFromWindow()
        }
        
        //Navigate to Register flow
        AppDelegate.shared.rootViewController.switchToRegister()
    }
}
