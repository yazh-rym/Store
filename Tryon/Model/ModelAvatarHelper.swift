//
//  ModelAvatarHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 16/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import Alamofire
import AWSS3
import SwiftyJSON
import RealmSwift
import SystemConfiguration



class ModelAvatarHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    var operationQueue: OperationQueue = OperationQueue()
    
    
    // MARK: - Model functions
    //Function to get model details
    func getModelDetails(completionHandler : @escaping (_ modelsAvatars: [ModelAvatar], _ error: NSError?) -> Void) {
        self.getAllModelAvatar { (modelAvatars, error) in
            var processingCompletedModelNames: [String] = []
            
            for model in modelAvatars {                
                self.getUserFromModel(modelName: model.modelName, shouldRenderImages: true, jsonUrl: model.jsonUrl, serverVideoUrl: model.serverVideoUrl, frontFaceImgUrl: model.frontFaceImgUrl, completionHandler: { (newUser) in
                    self.tryon3D.user = newUser
                    
                    processingCompletedModelNames.append((newUser?.internalUserName)!)
                    if processingCompletedModelNames.count == modelAvatars.count {
                        completionHandler(modelAvatars, error)
                    }
                })
            }
        }
    }
    
    //Function to get list of all models
    func getAllModelAvatar(completionHandler : @escaping (_ result: [ModelAvatar], _ error: NSError?) -> Void) {
        
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]
        
        //Get Model, irrespective of whether modelAvatars are already present or not
        Alamofire.request(EndPoints().getModelListUrl, method: .get, parameters: [:], headers: headers)
            .responseJSON { response in
                var modelAvatars = [ModelAvatar]()
                var getModelUnknownError: NSError?
                
                let realm = try! Realm()
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    
                    completionHandler(modelAvatars, error as NSError)
                    
                case .success(let responseObject):
                    if let models = responseObject as? [NSDictionary] {
                        for model in models {
                            let id = model.value(forKey: "id") as! Int
                            let modelName = model.value(forKey: "model_name") as! String
                            let frontFaceImgUrl = model.value(forKey: "front_face_url") as! String
                            let jsonUrl = model.value(forKey: "json_url") as! String
                            let serverVideoUrl = model.value(forKey: "video_url") as! String
                            
                            let order = model.value(forKey: "order") as! Int
                            let genderId = model.value(forKey: "gender_Id") as! Int
                            let gender = realm.objects(CategoryGender.self).filter("id in {\(genderId)}").first
                            let videoUrlComponents = serverVideoUrl.components(separatedBy: "/")
                            let fileName = videoUrlComponents.last
                            
                            let appVideoUrl = (FileHelper().getDocumentDirectoryPath() as NSString).appendingPathComponent(fileName!)
                            if FileHelper().fileExists(atPath: appVideoUrl) {
                                let modelAvatar = ModelAvatar(value: ["id": id, "modelName": modelName, "frontFaceImgUrl": frontFaceImgUrl, "jsonUrl": jsonUrl, "serverVideoUrl": serverVideoUrl, "appVideoUrl": appVideoUrl, "fileName": fileName!, "order": order, "gender": gender as Any])
                                
                                modelAvatars.append(modelAvatar)
                                
                                //Update the Model
                                if models.count == modelAvatars.count {
                                    completionHandler(modelAvatars, nil)
                                }
                            } else {
                                let downloadCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = { [fileName = fileName, appVideoUrl = appVideoUrl] (task, url, data, error) -> Void in
                                    if error == nil {
                                        log.info("Model Video Download - Completed for fileName: \(String(describing: fileName))")
                                        
                                        do {
                                            try data?.write(to: URL(fileURLWithPath: appVideoUrl))
                                        } catch {
                                            log.error("Model Video Save - Failed with error: \(error)")
                                        }
                                        
                                        let modelAvatar = ModelAvatar(value: ["id": id, "modelName": modelName, "frontFaceImgUrl": frontFaceImgUrl, "jsonUrl": jsonUrl, "serverVideoUrl": serverVideoUrl, "appVideoUrl": appVideoUrl, "fileName": fileName!, "order": order, "gender": gender as Any])
                                        
                                        modelAvatars.append(modelAvatar)
                                    } else {
                                        log.error("Model Video Download - Failed with error: \(String(describing: error))")
                                    }
                                    
                                    //Update the Model
                                    if models.count == modelAvatars.count {
                                        completionHandler(modelAvatars, nil)
                                    }
                                }
                                
                                self.operationQueue.maxConcurrentOperationCount = 4
                                let blockOperation: BlockOperation = BlockOperation.init(
                                    block: {
                                        AWSDownloadHelper().downloadFile(fileURL: NSURL(string: appVideoUrl)!, bucketName: EndPoints().s3BucketNameForModelVideoDownload, s3DownloadKeyName: fileName!, completionHandler: downloadCompletionHandler, progressBlock: nil)
                                })
                                blockOperation.queuePriority = .normal
                                self.operationQueue.addOperation(blockOperation)
                            }
                        }
                    } else {
                        var userInfo: [AnyHashable : Any] = [:]
                        let message: String = "Unknown Error"
                        
                        userInfo = [
                            NSLocalizedDescriptionKey : message,
                            NSLocalizedFailureReasonErrorKey : message
                        ]
                        getModelUnknownError = NSError(domain: EndPoints().getModelListUrl, code: 500, userInfo: userInfo)
                        completionHandler(modelAvatars, getModelUnknownError)
                    }
                }
        }
    }
    
    func getUserFromModel(modelName: String, shouldRenderImages: Bool, jsonUrl: String, serverVideoUrl: String, frontFaceImgUrl: String, completionHandler : @escaping (_ user: User?) -> Void) {
        self.getModelJson(jsonUrl: jsonUrl) { (processVideoResult, error) in
            if let error = error {
                //TODO: Handle this
                log.error("Get Model Json - Failed with error - \(error)")
                completionHandler(nil)
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
                
                let videoUrlComponents = serverVideoUrl.components(separatedBy: "/")
                let fileName = videoUrlComponents.last
                let appVideoUrl = (FileHelper().getDocumentDirectoryPath() as NSString).appendingPathComponent(fileName!)
                
                var appVideoFPS: Int? = 25
                if let fps = responseDict?.value(forKey: "video_fps") as? Int {
                    appVideoFPS = fps
                }
                
                let newUser = User(yprValues: yprValues, sellionPoints: sellionPoints, frameNumbers: frameNumbers, frontFrameIndex: frontFrameIndex, eyeToEyeDistance: eyeToEyeDistance, eyeFrameScaleFactor: eyeFrameScaleFactor, serverFaceSize: serverFaceSize, glassUrl: glassUrl, jsonUrl: jsonUrl, userType: UserType.model, serverVideoUrl: serverVideoUrl, frontFaceImgUrl: frontFaceImgUrl, internalUserName: modelName, shouldRenderImages: shouldRenderImages, appVideoUrl: appVideoUrl, appVideoFPS: appVideoFPS, userInputType: .video, image: nil)
                self.tryon3D.user = newUser
                
                completionHandler(newUser)
            }
        }
    }
    
    //Function to get the json for the selected model
    func getModelJson(jsonUrl: String, completionHandler : @escaping (_ result: NSDictionary?, _ error: NSError?) -> Void) {
        
        //The below method uses AWS download.
        /*
        let jsonUrlArray : [String] = jsonUrl.components(separatedBy: "/")
        
        let downloadCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = { (task, url, data, error) -> Void in
            var newResult: NSDictionary?
            var newError: NSError?
            var isError = false
            var message: String = "Unknown Error"
            
            if error == nil {
                if let data = data {
                    if let dict = JSON(data).dictionaryObject {
                        let responseDict = dict as NSDictionary
                        
                        if responseDict.value(forKey: "status") as! String == "success" || responseDict.value(forKey: "status") as! String == "OK" {
                            newResult = responseDict
                        } else {
                            isError = true
                            if let messageFromServer = responseDict.value(forKey: "message") as! String? {
                                message = messageFromServer
                            }
                        }
                    } else {
                        isError = true
                    }
                } else {
                    isError = true
                }
                
                if isError {
                    var userInfo: [AnyHashable : Any] = [:]

                    userInfo = [
                        NSLocalizedDescriptionKey : message,
                        NSLocalizedFailureReasonErrorKey : message
                    ]
                    newError = NSError(domain: jsonUrl, code: 500, userInfo: userInfo)
                }
                
                DispatchQueue.main.async {
                    completionHandler(newResult, newError)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(nil, error! as NSError)
                }
            }
        }
        
        AWSDownloadHelper().downloadFile(fileURL: NSURL(string: jsonUrl)!, bucketName: EndPoints().s3BucketNameForModelJsonDownload, s3DownloadKeyName: jsonUrlArray.last!, completionHandler: downloadCompletionHandler, progressBlock: nil)
        */
        
        Alamofire.request(jsonUrl, method: .get, parameters: nil)
            .responseJSON { response in
                var result: NSDictionary?
                var error: NSError?
                
                if response.result.isSuccess {
                    let responseDict = response.result.value as! NSDictionary
                    
                    if responseDict.value(forKey: "status") as! String == "success" || responseDict.value(forKey: "status") as! String == "OK" {
                        result = responseDict
                    }
                    else {
                        var userInfo: [AnyHashable : Any] = [:]
                        var message: String = "Unknown Error"
                        
                        if let messageFromServer = responseDict.value(forKey: "message") as! String? {
                            message = messageFromServer
                        }
                        
                        userInfo = [
                            NSLocalizedDescriptionKey : message,
                            NSLocalizedFailureReasonErrorKey : message
                        ]
                        error = NSError(domain: jsonUrl, code: 500, userInfo: userInfo)
                    }
                } else {
                    error = response.error! as NSError
                }
                completionHandler(result, error)
        }
    }
}

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}
