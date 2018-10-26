//
//  User.swift
//  Tryon
//
//  Created by Udayakumar N on 27/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import UIKit


enum UserType: String {
    case model = "M"
    case user = "U"
}

enum UserInputType: Int {
    case image = 0
    case video
}


class User: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    var operationQueue: OperationQueue = OperationQueue()
    var glassOperationQueue: OperationQueue = OperationQueue()
    var isAllFramesExtracted: Bool = false
    
    var userType: UserType = .model
    var userInputType: UserInputType = .video
    
    var internalUserName: String = ""
    var appVideoUrl: String = ""
    var appVideoFPS: Int = 25
    var shouldRenderImages: Bool = true
    var serverVideoUrl: String?
    
    var actualYPRValues: [String]? = []
    var yprValues: [String]? = []
    var sellionPoints: [CGPoint]? = []
    var frameNumbers: [Int]? = []
    var frontFrameIndex: Int?
    var eyeToEyeDistance: Double?
    var eyeFrameScaleFactor: Double?
    var serverFaceSize: CGSize?
    var glassUrl: String?
    var jsonUrl: String?
    var frontFaceImgUrl: String?
    
    var frontFrameIndexForInstant: Int?
    
    var image: UIImage?
    
    // MARK: - Class Functions
    init(yprValues: [String]?, sellionPoints: [CGPoint]?, frameNumbers: [Int]?, frontFrameIndex: Int?, eyeToEyeDistance: Double?, eyeFrameScaleFactor: Double?, serverFaceSize: CGSize?, glassUrl: String?, jsonUrl: String?, userType: UserType, serverVideoUrl: String?, frontFaceImgUrl: String?, internalUserName: String, shouldRenderImages: Bool, appVideoUrl: String, appVideoFPS: Int?, userInputType: UserInputType, image: UIImage?) {
        
        //Reduce the number of frames to 3 (right, left and center)
        /*
        self.yprValues = [(yprValues?.first)!]
        self.yprValues?.append(yprValues![frontFrameIndex!])
        self.yprValues?.append((yprValues?.last)!)
        self.sellionPoints = [(sellionPoints?.first)!]
        self.sellionPoints?.append(sellionPoints![frontFrameIndex!])
        self.sellionPoints?.append((sellionPoints?.last)!)
        self.frameNumbers = [(frameNumbers?.first)!]
        self.frameNumbers?.append(frameNumbers![frontFrameIndex!])
        self.frameNumbers?.append((frameNumbers?.last)!)
        self.frontFrameIndex = 1
         */
        
        //Use Prerendered YPR values for fetching the images
        let preRenderedY = [-45, -36, -27, -18, -9, -6, -3, 0, 3, 6, 9, 18, 27, 36, 45].sorted().reversed()
        let preRenderedP = [-21, -18, -12, -6, -3, 0, 3, 6, 12, 18, 21].sorted().reversed()
        let preRenderedR = [0].sorted().reversed()
        
        //Correct the values of p and r (by simple average)
        var yArray: [Double] = []
        var pArray: [Double] = []
        var rArray: [Double] = []
        var yprCorrectedArray: [String] = []
        for ypr in yprValues! {
            let yprArray = ypr.components(separatedBy: "_")
            let y = Double(yprArray[0])!
            let p = Double(yprArray[1])!
            let r = Double(yprArray[2])!

            yArray.append(y)
            pArray.append(p)
            rArray.append(r)
        }
        
        var z = 0
        for _ in yprValues! {
            var newYPR = ""
            var pAvg = pArray[z]
            var rAvg = rArray[z]
            
            //Find the average, only if there are more number of frames
            if ((yprValues?.count ?? 0) >= 3) {
                if z == 0 {
                    pAvg = (pArray[z] + pArray[z+1]) / 2
                    rAvg = (rArray[z] + rArray[z+1]) / 2
                } else if z == (yprValues?.count ?? 0) - 1 {
                    pAvg = (pArray[z-1] + pArray[z]) / 2
                    rAvg = (rArray[z-1] + rArray[z]) / 2
                } else {
                    pAvg = (pArray[z-1] + pArray[z] + pArray[z+1]) / 3
                    rAvg = (rArray[z-1] + rArray[z] + rArray[z+1]) / 3
                }
            }
            newYPR = String(describing: yArray[z]) + "_" + String(describing: pAvg) + "_" + String(describing: rAvg)
            yprCorrectedArray.append(newYPR)
            
            z = z + 1
        }
        
        for ypr in yprCorrectedArray {
            let yprArray = ypr.components(separatedBy: "_")
            let y = Double(yprArray[0])!
            let p = Double(yprArray[1])!
            let r = Double(yprArray[2])!
            
            var newY, newP, newR: Int?
            var prevY = preRenderedY.first
            var prevP = preRenderedP.first
            var prevR = preRenderedR.first
            
            //The values are sorted and reversed, to makes sure that the order is descending
            for i in preRenderedY {
                if y >= Double(i + (prevY! - i)/2) {
                    newY = prevY
                    break
                } else {
                    prevY = i
                }
            }
            
            for i in preRenderedP {
                if p >= Double(i + (prevP! - i)/2) {
                    newP = prevP
                    break
                } else {
                    prevP = i
                }
            }
            
            for i in preRenderedR {
                if r >= Double(i + (prevR! - i)/2) {
                    newR = prevR
                    break
                } else {
                    prevR = i
                }
            }
            
            //For extreme negative angle, the newY, newP and newR may be nil. So handle it.
            if newY == nil {
                newY = preRenderedY.last
            }
            
            if newP == nil {
                newP = preRenderedP.last
            }
            
            if newR == nil {
                newR = preRenderedR.last
            }
            
            let newYPR = String(describing: newY!) + "_" + String(describing: newP!) + "_" + String(describing: newR!)
            self.yprValues?.append(newYPR)
        }
        
        self.actualYPRValues = yprCorrectedArray
        self.sellionPoints = sellionPoints
        self.frameNumbers = frameNumbers
        self.frontFrameIndex = frontFrameIndex
        
        self.eyeToEyeDistance = eyeToEyeDistance
        self.eyeFrameScaleFactor = eyeFrameScaleFactor
        self.serverFaceSize = serverFaceSize
        
        self.glassUrl = EndPoints().s3PreRenderedUrl
        self.jsonUrl = EndPoints().s3PreRenderedUrl
        self.userType = userType
        self.serverVideoUrl = serverVideoUrl
        self.appVideoUrl = appVideoUrl
        if let fps = appVideoFPS {
            self.appVideoFPS = fps
        }
        self.userInputType = userInputType
        self.image = image
        
        self.frontFaceImgUrl = frontFaceImgUrl
        self.frontFrameIndexForInstant = frontFrameIndex
        var i = self.yprValues!.count - 1
        for ypr in self.yprValues!.reversed() {
            let yprArray = ypr.components(separatedBy: "_")
            if let yInt = Int(yprArray.first!) {
                if (yInt <= -15) && (yInt >= -28) {
                //The below if statement was used to display the user facing left. For this, remove reversed() and change i
                //if (yInt >= 10) && (yInt <= 28) {
                    self.frontFrameIndexForInstant = i
                    break
                }
            }
            i = i - 1
        }
        
        //Reduce the number of frames to 3 (right, left and center)
        /*
        var i = 0
        var j = 0
        var newYprValues: [String] = []
        var newSellionPoints: [CGPoint] = []
        var newFrameNumbers: [Int] = []
        for frameNumber in frameNumbers! {
            if frameNumber == self.frontFrameNumber! {
                //Take this value
                newYprValues.append((self.yprValues?[i])!)
                newSellionPoints.append((self.sellionPoints?[i])!)
                newFrameNumbers.append((self.frameNumbers?[i])!)
                self.frontFrameIndex = j
                self.frontFrameNumber = frameNumber
                j = j + 1
                
                continue
            }
            
            if (i % 3 == 0) {
                //Take this value
                newYprValues.append((self.yprValues?[i])!)
                newSellionPoints.append((self.sellionPoints?[i])!)
                newFrameNumbers.append((self.frameNumbers?[i])!)
                j = j + 1
            }
            
            i = i + 1
        }
        self.yprValues = newYprValues
        self.sellionPoints = newSellionPoints
        self.frameNumbers = newFrameNumbers
        */
        
        operationQueue.maxConcurrentOperationCount = 4
        operationQueue.qualityOfService = .background
        
        glassOperationQueue.maxConcurrentOperationCount = 4
        glassOperationQueue.qualityOfService = .background
        
        self.internalUserName = internalUserName
        self.shouldRenderImages = shouldRenderImages
        
        super.init()
        
        if self.shouldRenderImages {
            if userInputType == .video {
                getFrontFrame(forUserName: self.internalUserName, fromAppVideoUrl: self.appVideoUrl, appVideoFPS: self.appVideoFPS)
                DispatchQueue.global(qos: .userInitiated).sync {
                    self.getAllFrames(forUserName: self.internalUserName, fromAppVideoUrl: self.appVideoUrl, appVideoFPS: self.appVideoFPS, completionHandler: {
                        //TODO: All frames completed. Make use of this status
                    })
                }
            } else if userInputType == .image {
                getFrontFrame(forUserName: self.internalUserName, fromImage: image!)
                getAllFrames(forUserName: self.internalUserName, fromImage: image!)
            }
        }
    }
    
    func getFrontFrame(forUserName userName: String, fromAppVideoUrl videoUrl: String, appVideoFPS: Int) {
        //Get front face image
        if let frontFaceImage = ImageHelper().image(fromVideoUrl: URL(fileURLWithPath: videoUrl), atTime: CMTimeMake(Int64((self.frameNumbers?[self.frontFrameIndex!])!), Int32(appVideoFPS))) {
            let identifier = userName + "-frontFace"
            CacheHelper().add(frontFaceImage, withIdentifier: identifier, in: "jpg")
        } else {
            log.warning("FrontFrame couldn't be extracted")
        }
    }
    
    func getAllFrames(forUserName userName: String, fromAppVideoUrl videoUrl: String, appVideoFPS: Int, completionHandler: @escaping () -> Void) {
        //Get all the frames
        for frameNumber in self.frameNumbers! {
            let time = CMTimeMake(Int64(frameNumber), Int32(appVideoFPS))
            
            let blockOperation: BlockOperation = BlockOperation.init(
                block: { [a = frameNumber] in
                    let identifier = userName + "-user-" + String(a)
                    
                    if let img = ImageHelper().image(fromVideoUrl: URL(fileURLWithPath: videoUrl), atTime: time) {
                        log.info("Getting user frame for \(identifier)")
                        CacheHelper().add(img, withIdentifier: identifier, in: "jpg")
                    } else {
                        log.warning("UserImage couldn't be extracted for identifier: \(identifier)")
                    }
                    
                    if self.operationQueue.operationCount == 0 {
                        self.isAllFramesExtracted = true
                        completionHandler()
                    }
            })
            
            blockOperation.queuePriority = .high
            operationQueue.addOperation(blockOperation)
        }
    }
    
    func getFrontFrame(forUserName userName: String, fromImage image: UIImage) {
        //For image, use the image itself as front image
        let identifier = userName + "-frontFace"
        CacheHelper().add(image, withIdentifier: identifier, in: "jpg")
    }
    
    func getAllFrames(forUserName userName: String, fromImage image: UIImage) {
        //Set the image as frame number 1
        let identifier = userName + "-user-" + String(1)
        CacheHelper().add(image, withIdentifier: identifier, in: "jpg")
    }
}
