//
//  TryonModel.swift
//  Tryon
//
//  Created by Udayakumar N on 14/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import AlamofireImage
import SwiftyBeaver

enum Environment: String {
    case staging = "STAGING"
    case production = "PRODUCTION"
}

class TryonModel {
    static let sharedInstance: TryonModel = {
        let instance = TryonModel()
        
        //Initialize Tryon3D data
        let _ = Tryon3D.sharedInstance

        return instance
    }()
    
    private init() {
        //Initialize Access Token
        let userDefaults = UserDefaults.standard
        if let accessToken = userDefaults.value(forKey: "accessToken") as? String {
            if accessToken != "" {
                self.accessToken = accessToken
            }
        }
        
        if let userId = userDefaults.value(forKey: "userId") as? Int {
            if userId != 0 {
                self.userId = userId
            }
        }
    }

    // MARK: - Class variables
    var accessToken: String = "" {
        didSet {
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(accessToken, forKey: "accessToken")
            userDefaults.synchronize()
        }
    }
    
    var userId: Int = 0 {
        didSet {
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(userId, forKey: "userId")
            userDefaults.synchronize()
        }
    }
    var relatedDBUsers: [DBUser] = []
    var trayInventoryFrames = [InventoryFrame]()
    var favInventoryFrames = [InventoryFrame]()

    var volumeIsMute: Bool = false
    
    //Initialize Configuration
    var environment: Environment = .staging
    
    let appVideoFrameRate = 30
    let maxNumberOf3DFrames = 15
    let trimVideoBasedOnFaceX = true
    
    //Configure Cache
    let imageCache = AutoPurgingImageCache(
        memoryCapacity: 100_000_000,
        preferredMemoryUsageAfterPurge: 60_000_000
    )
    
    //Have bigger value for appVideoBitRate
    let appVideoBitRate: Float = 10_000_000
    let serverVideoBitRate: Float = 1_000_000
    let serverImageJPGCompression: CGFloat = 0.5
    
    //Variables for Calculations
    let serverVideoSize = CGSize(width: 360, height: 640)
    let serverImageSize = CGSize(width: 360, height: 480)
    //Size in which the image/video is taken. Default value is that of Video.
    var displayImageSize = CGSize(width: 720, height: 960)
}
