//
//  UserRenderHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 27/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import Alamofire

class UserRenderHelper: NSObject {
    
    // MARK: - Class variables
    static let model = TryonModel.sharedInstance
    
    
    // MARK: - User Render
    func getGlassCenterJson(jsonUrl: String, frameUuid: String, glassImageForScalingUrl: String, completionHandler: @escaping (_ result: CGPoint?, _ glassSizeForScaling: CGSize?, _ error: NSError?) -> Void) {
        Alamofire.request(jsonUrl, method: .get, parameters: nil)
            .responseJSON { response in
                var error: NSError?
                var glassCenterPoint: CGPoint?
                var glassSizeForScaling = CGSize.zero
                
                if response.result.isSuccess {
                    let resultDict = response.result.value as? NSDictionary
                    
                    let jsonArray = jsonUrl.components(separatedBy: "/")
                    let imageName = jsonArray.last
                    let yprArray = imageName?.components(separatedBy: ".")
                    let ypr = yprArray?.first
                    let dictKey = frameUuid + "/Images/" + ypr! + ".png"
                    
                    if let pointArray = resultDict?.value(forKey: dictKey) as? [Int] {
                        glassCenterPoint = CGPoint(x: pointArray[0], y: pointArray[1])
                        
                        //Check for 0_0_0 dimension
                        if let zeroArray = resultDict?.value(forKey: "dimension_0") as? [Int] {
                            glassSizeForScaling = CGSize(width: zeroArray[1], height: zeroArray[0])
                            
                            completionHandler(glassCenterPoint, glassSizeForScaling, error)
                            
                        } else {
                            //Get the image for scaling and get the dimension
                            UserRenderHelper().getGlassImage(fromUrl: glassImageForScalingUrl) { (image, getGlassImageError) in
                                if getGlassImageError == nil {
                                    glassSizeForScaling = CGSize(width: (image?.width)! * (image?.scale)!, height: (image?.height)! * (image?.scale)!)
                                } else {
                                    error = response.error! as NSError
                                }
                                completionHandler(glassCenterPoint, glassSizeForScaling, error)
                            }
                        }
                    } else {
                        //Error in getting glass center
                        var error: NSError?
                        var userInfo: [AnyHashable : Any] = [:]
                        let message: String = "Error in getting glass center from \(jsonUrl)"
                        
                        userInfo = [
                            NSLocalizedDescriptionKey : message,
                            NSLocalizedFailureReasonErrorKey : message
                        ]
                        error = NSError(domain: jsonUrl, code: 500, userInfo: userInfo)
                        log.error(message)
                        
                        completionHandler(glassCenterPoint, glassSizeForScaling, error)
                    }
                } else {
                    error = response.error! as NSError
                    completionHandler(glassCenterPoint, glassSizeForScaling, error)
                }
        }
    }
    
    func getGlassImage(fromUrl url: String?, completionHandler : @escaping (_ result: UIImage?, _ error: NSError?) -> Void) {
        //Check input parameters
        guard let url = url else {
            var error: NSError?
            var userInfo: [AnyHashable : Any] = [:]
            let message: String = "Invalid Input Parameter"
            
            userInfo = [
                NSLocalizedDescriptionKey : message,
                NSLocalizedFailureReasonErrorKey : message
            ]
            error = NSError(domain: "getGlassUrl", code: 500, userInfo: userInfo)
            
            completionHandler(nil, error)
            return
        }
        
        Alamofire.request(url, method: .get, parameters: nil).responseImage { response in
            var error: NSError?
            var newGlassImage: UIImage?
            
            if response.result.isSuccess {
                if let glassImage = response.result.value {
                    newGlassImage = glassImage
                    
                } else {
                    var userInfo: [AnyHashable : Any] = [:]
                    let message: String = "Glass image could not be downloaded from \(url)"
                    
                    userInfo = [
                        NSLocalizedDescriptionKey : message,
                        NSLocalizedFailureReasonErrorKey : message
                    ]
                    error = NSError(domain: url, code: 500, userInfo: userInfo)
                }
            } else {
                error = response.error! as NSError
            }
            completionHandler(newGlassImage, error)
        }
    }
    
    func createGlassImage(forUser user: User?, glassUrl: String?, glassSizeForScaling: CGSize?, glassCenter: CGPoint?, sellionPoint: CGPoint?, faceSize: CGSize?, withUserImage userImage: UIImage?, completionHandler : @escaping (_ result: UIImage?, _ error: NSError?) -> Void) {
        //Check input parameters
        guard let user = user, let glassUrl = glassUrl, let glassCenter = glassCenter, let sellionPoint = sellionPoint, let faceSize = faceSize else {
            var error: NSError?
            var userInfo: [AnyHashable : Any] = [:]
            let message: String = "Invalid Input Parameter"
            
            userInfo = [
                NSLocalizedDescriptionKey : message,
                NSLocalizedFailureReasonErrorKey : message
            ]
            error = NSError(domain: EndPoints().getModelListUrl, code: 500, userInfo: userInfo)
            
            completionHandler(nil, error)
            return
        }
        
        Alamofire.request(glassUrl, method: .get, parameters: nil).responseImage { response in
            var error: NSError?
            var newGlassImage: UIImage?
            
            DispatchQueue.global(qos: .background).sync {
                if response.result.isSuccess {
                    if let glassImage = response.result.value {
                        
                        //Get the size of the downloaded glass
                        let glassImageSize = CGSize(width: glassImage.size.width * glassImage.scale, height: glassImage.size.height * glassImage.scale)
                        
                        //For Scaling, use glassSizeForScaling's width
                        //Find the scaling factor to be applied to the downloaded glass image
                        let scalingFactor: CGFloat = CGFloat(user.eyeToEyeDistance! / Double(glassSizeForScaling!.width) * user.eyeFrameScaleFactor!)
                        
                        //Find the scaling factor of the image with respect to the display
                        let imageScalingFactor: CGFloat = CGFloat(UserRenderHelper.model.displayImageSize.width / faceSize.width)
                        
                        //Find the new glass image size after applying all these scaling factors
                        let newGlassImageSize = CGSize(width: glassImageSize.width * scalingFactor * imageScalingFactor, height: glassImageSize.height * scalingFactor * imageScalingFactor)
                        
                        //Rescale the image
                        let scaledGlassImage = glassImage.af_imageScaled(to: newGlassImageSize)
                        
                        //Find the new Glass Origin based on Sellion Point, Glass Center and Scaling factors
                        let newGlassOriginX = (sellionPoint.x - glassCenter.x * scalingFactor) * imageScalingFactor
                        let newGlassOriginY = (sellionPoint.y - glassCenter.y * scalingFactor) * imageScalingFactor
                        
                        //Usually, correctionFactorX will be 0
                        let correctionFactorX = (faceSize.width * imageScalingFactor - UserRenderHelper.model.displayImageSize.width) / 2
                        let correctionFactorY = (faceSize.height * imageScalingFactor - UserRenderHelper.model.displayImageSize.height) / 2
                        
                        UIGraphicsBeginImageContextWithOptions(UserRenderHelper.model.displayImageSize, false, 0.0)
                        if let img = userImage {
                            let scaledImage = img.af_imageScaled(to: UserRenderHelper.model.displayImageSize)
                            scaledImage.draw(at: CGPoint.zero)
                        }
                        
                        scaledGlassImage.draw(in: CGRect(origin: CGPoint(x: newGlassOriginX - correctionFactorX, y: newGlassOriginY - correctionFactorY), size: scaledGlassImage.size))
                        
                        //Draw rectangle around sellion point, for testing
                        //let rectangle = CGRect(x: sellionPoint.x - 2 - correctionFactorX, y: sellionPoint.y - 2 - correctionFactorY, width: 4, height: 4)
                        //let context = UIGraphicsGetCurrentContext
                        //context()?.setFillColor(UIColor.red.cgColor)
                        //context()?.addRect(rectangle)
                        //context()?.drawPath(using: .fill)
                        
                        newGlassImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                    } else {
                        var userInfo: [AnyHashable : Any] = [:]
                        let message: String = "Glass image could not be downloaded from \(glassUrl)"
                        
                        userInfo = [
                            NSLocalizedDescriptionKey : message,
                            NSLocalizedFailureReasonErrorKey : message
                        ]
                        error = NSError(domain: EndPoints().getModelListUrl, code: 500, userInfo: userInfo)
                    }
                } else {
                    error = response.error! as NSError
                }
                
                DispatchQueue.main.async() {
                    completionHandler(newGlassImage, error)
                }
            }
        }
    }
}
