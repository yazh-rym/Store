//
//  ModelHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 23/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import Alamofire
import AWSS3


class ModelHelper: NSObject {

    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    var operationQueue: OperationQueue = OperationQueue()
    
    
    // MARK: - Model functions
    func getModelDetails(completionHandler : @escaping () -> Void) {
        //TODO: Remove these hardcoded values
        let jsonUrl = "https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/models/model1.json"
        let frontFaceImgUrl = "https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/models/model1.jpg"
        let serverVideoUrl = "https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/models/model1.mp4"
        
        let videoUrlComponents = serverVideoUrl.components(separatedBy: "/")
        let fileName = videoUrlComponents.last
        let appVideoUrl = (FileHelper().getDocumentDirectoryPath() as NSString).appendingPathComponent(fileName!)
        self.model.appVideoUrl = URL(fileURLWithPath: appVideoUrl)
        
        if FileHelper().fileExists(atPath: appVideoUrl) {
            //Model Video is already available
            
            getModelJson(jsonUrl: jsonUrl, serverVideoUrl: serverVideoUrl, frontFaceImgUrl: frontFaceImgUrl, completionHandler: {
                completionHandler()
            })
        } else {
            let downloadCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = { [fileName = fileName, appVideoUrl = appVideoUrl] (task, url, data, error) -> Void in
                if error == nil {
                    log.info("Model Video Download - Completed for fileName: \(String(describing: fileName))")
                    
                    do {
                        try data?.write(to: URL(fileURLWithPath: appVideoUrl))
                        
                        self.getModelJson(jsonUrl: jsonUrl, serverVideoUrl: serverVideoUrl, frontFaceImgUrl: frontFaceImgUrl, completionHandler: {
                            completionHandler()
                        })
                    } catch {
                        log.error("Model Video Save - Failed with error: \(error)")
                    }
                } else {
                    log.error("Model Video Download - Failed with error: \(String(describing: error))")
                }
            }
            
            AWSDownloadHelper().downloadFile(fileURL: NSURL(string: appVideoUrl)!, bucketName: EndPoints().s3BucketNameForModelVideoDownload, s3DownloadKeyName: fileName!, completionHandler: downloadCompletionHandler, progressBlock: nil)
        }
    }
    
    func getModelJson(jsonUrl: String, serverVideoUrl: String, frontFaceImgUrl: String, completionHandler : @escaping () -> Void) {
        self.getModelJson(jsonUrl: jsonUrl) { (processVideoResult, error) in
            if let error = error {
                //TODO: Handle this
                log.error("Get Model Json - Failed with error - \(error)")
                completionHandler()
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
                
                //Remove old files
                FileHelper().removeAllFilesFromCache()
                self.model.imageCache.removeAllImages()
                
                let newUser = User(yprValues: yprValues, sellionPoints: sellionPoints, frameNumbers: frameNumbers, frontFrameIndex: frontFrameIndex, eyeToEyeDistance: eyeToEyeDistance, eyeFrameScaleFactor: eyeFrameScaleFactor, serverFaceSize: serverFaceSize, glassUrl: glassUrl, jsonUrl: jsonUrl, userType: UserType.model, serverVideoUrl: serverVideoUrl, frontFaceImgUrl: frontFaceImgUrl)
                self.tryon3D.user = newUser
                
                completionHandler()
            }
        }
    }
    
    
    
    
    
    // MARK: - Model functions
    //Function to get list of all models
    func getModelAvatar(completionHandler : @escaping (_ result: [ModelAvatar], _ error: NSError?) -> Void) {
        if model.modelAvatars.count > 0 {
            completionHandler(model.modelAvatars, nil)
        }
        
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]
        
        //Get Model, irrespective of whether modelAvatars are already present or not
        Alamofire.request(EndPoints().getModelListUrl, method: .get, parameters: [:], headers: headers)
            .responseJSON { response in
                var modelAvatars = [ModelAvatar]()
                var getModelUnknownError: NSError?
                
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
                            
                            //TODO: Change id to order key
                            let order = model.value(forKey: "id") as! Int
                            let videoUrlComponents = serverVideoUrl.components(separatedBy: "/")
                            let fileName = videoUrlComponents.last
                            
                            let appVideoUrl = (FileHelper().getDocumentDirectoryPath() as NSString).appendingPathComponent(fileName!)
                            if FileHelper().fileExists(atPath: appVideoUrl) {
                                let modelAvatar = ModelAvatar(id: id, modelName: modelName, frontFaceImgUrl: frontFaceImgUrl, jsonUrl: jsonUrl, serverVideoUrl: serverVideoUrl, appVideoUrl: appVideoUrl, fileName: fileName!, order: order)
                                
                                modelAvatars.append(modelAvatar)
                            } else {
                                let downloadCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = { [fileName = fileName, appVideoUrl = appVideoUrl] (task, url, data, error) -> Void in
                                    if error == nil {
                                        log.info("Model Video Download - Completed for fileName: \(String(describing: fileName))")
                                        
                                        do {
                                            try data?.write(to: URL(fileURLWithPath: appVideoUrl))
                                        } catch {
                                            log.error("Model Video Save - Failed with error: \(error)")
                                        }
                                        
                                        let modelAvatar = ModelAvatar(id: id, modelName: modelName, frontFaceImgUrl: frontFaceImgUrl, jsonUrl: jsonUrl, serverVideoUrl: serverVideoUrl, appVideoUrl: appVideoUrl, fileName: fileName!, order: order)
                                        
                                        modelAvatars.append(modelAvatar)
                                    } else {
                                        log.error("Model Video Download - Failed with error: \(String(describing: error))")
                                    }
                                    
                                    //Update the Model
                                    if self.operationQueue.operationCount == 0 {
                                        DispatchQueue.main.async {
                                            self.model.modelAvatars = modelAvatars.sorted { $0.order < $1.order }
                                            completionHandler(modelAvatars, error as NSError?)
                                        }
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
                        
                        //Update the Model
                        if self.operationQueue.operationCount == 0 {
                            self.model.modelAvatars = modelAvatars.sorted { $0.order < $1.order }
                            completionHandler(self.model.modelAvatars, nil)
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
}
