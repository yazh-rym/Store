//
//  CollectionHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 10/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class CollectionHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    // MARK: - Get Collection data
    func getCollectionDistributor(completionHandler : @escaping (_ result: [CollectionDistributor], _ error: NSError?) -> Void) {
        
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]
        let parameters: Parameters = [
            "filter": ["order": "order ASC"]
        ]
        
        Alamofire.request(EndPoints().getCollectionDistributorUrl, method: .get, parameters: parameters, headers: headers)
            .responseJSON { response in
                var collectionDistributors: [CollectionDistributor] = []
                var error: NSError?
                
                var userInfo: [AnyHashable : Any] = [:]
                let message: String = "Unknown Error"
                userInfo = [
                    NSLocalizedDescriptionKey : message,
                    NSLocalizedFailureReasonErrorKey : message
                ]
                let unknownError = NSError(domain: EndPoints().getCollectionDistributorUrl, code: 500, userInfo: userInfo)
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    
                    completionHandler(collectionDistributors, error as NSError)
                    
                case .success(let responseObject):
                    if let collections = responseObject as? [NSDictionary] {
                        for collection in collections {
                            let id = collection.value(forKey: "id") as! Int
                            let name = collection.value(forKey: "collection_name") as! String
                            let imageUrl = collection.value(forKey: "collection_image_url") as? String
                            let bannerImageUrl = collection.value(forKey: "collection_bannerimage_url") as? String
                            let order = collection.value(forKey: "order") as! Int
                            
                            let collectionDistributor = CollectionDistributor(value: ["id": id, "name": name, "imageUrl": imageUrl as Any, "bannerImageUrl": bannerImageUrl as Any, "order": order])
                            
                            collectionDistributors.append(collectionDistributor)
                        }
                    } else if let errorResponse = (responseObject as AnyObject).value(forKey: "error") as? NSDictionary {
                        //Error
                        let statusCode = errorResponse.value(forKey: "statusCode") as? Int
                        let message = errorResponse.value(forKey: "message") as? String
                        let userInfo = [
                            NSLocalizedDescriptionKey : message!,
                            NSLocalizedFailureReasonErrorKey : message!
                        ]
                        
                        error = NSError(domain: EndPoints().getCollectionDistributorUrl, code: statusCode!, userInfo: userInfo)
                    } else {
                        //Unknown error
                        error = unknownError
                    }
                    completionHandler(collectionDistributors, error)
                }
        }
    }
    
    func getCollectionDistributorFrame(forCollectionId collectionId: Int, completionHandler : @escaping (_ result: [InventoryFrame], _ error: NSError?) -> Void) {
        
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]
        let parameters: Parameters = [
            "filter": ["order": "order ASC", "where": ["collection_dist_Id": String(collectionId)]]
        ]
        
        Alamofire.request(EndPoints().getCollectionDistributorFrameUrl, method: .get, parameters: parameters, headers: headers)
            .responseJSON { response in
                var inventoryFrames: [InventoryFrame] = []
                var error: NSError?
                
                var userInfo: [AnyHashable : Any] = [:]
                let message: String = "Unknown Error"
                userInfo = [
                    NSLocalizedDescriptionKey : message,
                    NSLocalizedFailureReasonErrorKey : message
                ]
                let unknownError = NSError(domain: EndPoints().getCollectionDistributorFrameUrl, code: 500, userInfo: userInfo)
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    
                    completionHandler(inventoryFrames, error as NSError)
                    
                case .success(let responseObject):
                    if let framesObjects = responseObject as? [NSDictionary] {
                        for frameObject in framesObjects {
                            let collectionFrameObject = frameObject.value(forKey: "collection_dist_frame_") as? NSDictionary
                            if let frame = collectionFrameObject?.value(forKey: "frame") as? NSDictionary {
                                inventoryFrames.append(InventoryFrameHelper().getInventoryFrameObject(fromObject: frame))
                            }
                        }
                    } else if let errorResponse = (responseObject as AnyObject).value(forKey: "error") as? NSDictionary {
                        //Error
                        let statusCode = errorResponse.value(forKey: "statusCode") as? Int
                        let message = errorResponse.value(forKey: "message") as? String
                        let userInfo = [
                            NSLocalizedDescriptionKey : message!,
                            NSLocalizedFailureReasonErrorKey : message!
                        ]
                        
                        error = NSError(domain: EndPoints().getCollectionDistributorFrameUrl, code: statusCode!, userInfo: userInfo)
                    } else {
                        //Unknown error
                        error = unknownError
                    }
                    completionHandler(inventoryFrames, error)
                }
        }
    }
}
