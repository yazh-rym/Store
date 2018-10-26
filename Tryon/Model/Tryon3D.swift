//
//  Tryon3D.swift
//  Tryon
//
//  Created by Udayakumar N on 29/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import UIKit


class Tryon3D: NSObject {
    
    static let sharedInstance: Tryon3D = {
        let instance = Tryon3D()
        return instance
    }()
    
    lazy var model = TryonModel.sharedInstance

    var user: User?
    var isUserSelectedByAppUser = false
    
    func getRender3D(forUser user: User, shouldRenderWithUserImage: Bool, frame: InventoryFrame, inDirectory directory: FileManager.SearchPathDirectory, completionHandler : @escaping (_ result: Render3D?) -> Void) {
        var resultRender3D: Render3D?
        
        let uuid = frame.uuid
        
        let glassPath = (user.glassUrl)! + uuid + "/Images/"
        let jsonPath = (user.jsonUrl)! + uuid + "/jsons/"
        
        var glassCenterDict: [Int: CGPoint] = [:]
        var isAllGlassCenterDownloaded = false
        var j = 0
        
        //Cancel all previous operations
        user.glassOperationQueue.cancelAllOperations()
        
        for frameNumber in (user.frameNumbers)! {
            let jsonUrl = jsonPath + (user.yprValues?[j])! + ".json"
            glassCenterDict.updateValue(CGPoint.zero, forKey: frameNumber)
            
            let blockOperation: BlockOperation = BlockOperation.init(
                block: {
                    let glassImageForScalingUrl = glassPath + "0_0_0.png"
                    
                    UserRenderHelper().getGlassCenterJson(jsonUrl: jsonUrl, frameUuid: uuid, glassImageForScalingUrl: glassImageForScalingUrl, completionHandler: { [frameNumber = frameNumber] (glassCenter, glassSizeForScaling, error) in
                        if error == nil {
                            glassCenterDict.updateValue(glassCenter!, forKey: frameNumber)
                            
                            var stillLoading = false
                            for glassCenter in glassCenterDict.values {
                                if glassCenter == CGPoint.zero {
                                    stillLoading = true
                                    break
                                }
                            }
                            
                            if stillLoading == false {
                                isAllGlassCenterDownloaded = true
                            }
                            
                            if isAllGlassCenterDownloaded {
                                var i = 0
                                var glassImageDict: [Int: Bool] = [:]
                                
                                for frameNumber in (user.frameNumbers)! {
                                    let glassUrl = glassPath + (user.yprValues?[i])! + ".png"
                                    glassImageDict.updateValue(false, forKey: frameNumber)
                                    
                                    let identifier = String(frame.id) + "-\(String(describing: frameNumber))"
                                    let userIdentifier = (self.user?.internalUserName)! + "-user-\(String(describing: frameNumber))"
                                    var userImage: UIImage?
                                    if shouldRenderWithUserImage {
                                        if let img = CacheHelper().image(withIdentifier: userIdentifier, in: "jpg") {
                                            userImage = img
                                        }
                                    }
                                    
                                    UserRenderHelper().createGlassImage(forUser: user, glassUrl: glassUrl, glassSizeForScaling: glassSizeForScaling, glassCenter: glassCenterDict[frameNumber], sellionPoint: user.sellionPoints?[i], faceSize: user.serverFaceSize, withUserImage: userImage, completionHandler: { [frameNumber = frameNumber, identifier = identifier] (glassImage, error) in
                                        
                                        if error == nil {
                                            let blockOperation: BlockOperation = BlockOperation.init(
                                                block: {
                                                    //Check whether glass Image is created or not
                                                    if let glassImage = glassImage {
                                                        if directory == .cachesDirectory {
                                                            CacheHelper().addToCache(glassImage, withIdentifier: identifier)
                                                        } else {
                                                            if shouldRenderWithUserImage {
                                                                CacheHelper().add(glassImage, withIdentifier: identifier, in: "jpg")
                                                            } else {
                                                                CacheHelper().add(glassImage, withIdentifier: identifier, in: "png")
                                                            }
                                                        }
                                                        
                                                        DispatchQueue.main.async {
                                                            glassImageDict.updateValue(true, forKey: frameNumber)
                                                            
                                                            var isAllGlassImageCreated = true
                                                            for isGlassCreated in glassImageDict.values {
                                                                if isGlassCreated == false {
                                                                    isAllGlassImageCreated = false
                                                                    break
                                                                }
                                                            }
                                                            
                                                            if isAllGlassImageCreated {
                                                                resultRender3D = Render3D(frameId: frame.id, status: Render3DStatus.isCompleted)
                                                                
                                                                completionHandler(resultRender3D)
                                                            }
                                                        }
                                                    }
                                            })
                                            blockOperation.queuePriority = .normal
                                            user.glassOperationQueue.addOperation(blockOperation)
                                        }
                                    })
                                    i = i + 1
                                }
                            }
                        } else {
                            log.error("Error in getting glass center from \(jsonUrl)")
                            completionHandler(nil)
                        }
                    })
            })
            
            blockOperation.queuePriority = .normal
            user.glassOperationQueue.addOperation(blockOperation)
            
            j = j + 1
        }
    }
}
