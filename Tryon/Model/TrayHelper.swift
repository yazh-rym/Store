//
//  TrayHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 24/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift


class TrayHelper: NSObject {
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    let realm = try! Realm()
    
    // MARK: - Cart functions
    func trayInventoryFrames() -> [InventoryFrame] {
        return self.model.trayInventoryFrames
    }
    
    func trayInventoryFramesCount() -> Int {
        return self.model.trayInventoryFrames.count
    }
    
    func addInventoryFrameToTray(_ inventoryFrame: InventoryFrame) -> Bool {
        let shouldBeAdded = !self.isAlreadyAvailbleInTray(inventoryFrame)
        
        if shouldBeAdded {
            self.model.trayInventoryFrames.append(inventoryFrame)
        } else {
            try! realm.write {
                inventoryFrame.orderQuantityCount = 1
            }
            self.model.trayInventoryFrames = self.model.trayInventoryFrames.filter { $0.uuid != inventoryFrame.uuid }
        }
        
        return shouldBeAdded
    }
    
    func addInventoryFrameToTrays(_ inventoryFrame: InventoryFrame) -> Bool {
        self.model.trayInventoryFrames.append(inventoryFrame)
        return true
    }
    
    func removeAllInventoryFrameFromTray() {
        for frame in self.trayInventoryFrames() {
            try! realm.write {
                frame.orderQuantityCount = 1
            }
        }
        self.model.trayInventoryFrames.removeAll()
    }
    
    func isAlreadyAvailbleInTray(_ inventoryFrame: InventoryFrame) -> Bool {
        var isAlreadyAvailable = false
        
        //Check whether it is already added
        for frame in self.model.trayInventoryFrames {
            if frame.uuid == inventoryFrame.uuid {
                isAlreadyAvailable = true
                return isAlreadyAvailable
            }
        }
        
        return false
    }
    
    func orderItems(orderbyId: Int, accountId: Int, frameId: Int, quantity: Int, orderDatetime: Date, orderStatusId: Int, completionHandler : @escaping (_ status: Bool, _ error: NSError?) -> Void) {
        
        let currentTimeInterval = (Date().timeIntervalSince1970 * 1000.0).rounded()
        
        let parameterDict = [
            "orderby_id" : orderbyId,
            "account_id" : accountId,
            "frame_id" : frameId,
            "quantity_original" : quantity,
            "quantity_approved" : quantity,
            "quantity_delivered" : quantity,
            "order_status_id": orderStatusId,
            "order_datetime": (orderDatetime.timeIntervalSince1970 * 1000.0).rounded(),
            "create_datetime": currentTimeInterval,
            "update_datetime": currentTimeInterval,
            ] as [String : Any]
        let parameterJson = JSON(parameterDict)
        let parameter = parameterJson.rawString()
        
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]
        
        Alamofire.request(EndPoints().placeOrderItemsUrl, method: .post, parameters: [:], encoding: parameter!, headers: headers)
            .responseJSON { response in
                var status = false
                var error: NSError?
                
                var userInfo: [AnyHashable : Any] = [:]
                let message: String = "Unknown Error"
                userInfo = [
                    NSLocalizedDescriptionKey : message,
                    NSLocalizedFailureReasonErrorKey : message
                ]
                let unknownError = NSError(domain: EndPoints().placeOrderItemsUrl, code: 500, userInfo: userInfo)
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    
                    completionHandler(status, error as NSError)
                    
                case .success(let responseObject):
                    status = true
                    if let result = responseObject as? NSDictionary {
                        if let _ = result.value(forKey: "id") as? Int {
                            status = true
                        }
                    } else if let errorResponse = (responseObject as AnyObject).value(forKey: "error") as? NSDictionary {
                        //Error
                        let statusCode = errorResponse.value(forKey: "statusCode") as? Int
                        let message = errorResponse.value(forKey: "message") as? String
                        let userInfo = [
                            NSLocalizedDescriptionKey : message!,
                            NSLocalizedFailureReasonErrorKey : message!
                        ]
                        
                        error = NSError(domain: EndPoints().placeOrderItemsUrl, code: statusCode!, userInfo: userInfo)
                    } else {
                        //Unknown error
                        error = unknownError
                    }
                    
                    completionHandler(status, error)
                }
        }
    }
    
    func addItemsToCart(orderbyId: Int, accountId: Int, frameIds: [Int], quantity: [Int], orderDatetime: Date, orderStatusId: Int, completionHandler : @escaping (_ result: [NSDictionary], _ error: NSError?) -> Void) {
        
        let currentTimeInterval = (Date().timeIntervalSince1970 * 1000.0).rounded()
        
        var paramDict: [[String : Any]] = []
        var i = 0
        for id in frameIds {
            let parameterDict = [
                "orderby_id" : orderbyId,
                "account_id" : accountId,
                "frame_id" : id,
                "quantity_original" : quantity[i],
                "quantity_approved" : quantity[i],
                "quantity_delivered" : quantity[i],
                "order_status_id": orderStatusId,
                "order_datetime": (orderDatetime.timeIntervalSince1970 * 1000.0).rounded(),
                "create_datetime": currentTimeInterval,
                "update_datetime": currentTimeInterval,
                ] as [String : Any]
            paramDict.append(parameterDict)
            i = i + 1
        }
        
        let parameterJson = JSON(paramDict)
        let parameter = parameterJson.rawString()
        
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]
        
        print(parameter!)
        Alamofire.request(EndPoints().addItemsToCart, method: .post, parameters: [:], encoding: parameter!, headers: headers)
            .responseJSON { response in
                var orderDetails: [NSDictionary] = []
                var returnError: NSError?
                
                var userInfo: [AnyHashable : Any] = [:]
                let message: String = "Unknown Error"
                userInfo = [
                    NSLocalizedDescriptionKey : message,
                    NSLocalizedFailureReasonErrorKey : message
                ]
                let unknownError = NSError(domain: EndPoints().addItemsToCart, code: 500, userInfo: userInfo)
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    
                    returnError = error as NSError
                    
                case .success(let responseObject):
                    if let result = responseObject as? NSDictionary {
                        if let items = result.value(forKey: "cartList") as? [NSDictionary] {
                            orderDetails = items
                        }
                    } else if let errorResponse = (responseObject as AnyObject).value(forKey: "error") as? NSDictionary {
                        //Error
                        let statusCode = errorResponse.value(forKey: "statusCode") as? Int
                        let message = errorResponse.value(forKey: "message") as? String
                        let userInfo = [
                            NSLocalizedDescriptionKey : message!,
                            NSLocalizedFailureReasonErrorKey : message!
                        ]
                        
                        returnError = NSError(domain: EndPoints().addItemsToCart, code: statusCode!, userInfo: userInfo)
                    } else {
                        //Unknown error
                        returnError = unknownError
                    }
                }
                completionHandler(orderDetails, returnError)
        }
    }
    
    func placeOrder(orderbyId: Int, accountId: Int, itemDetails: [NSDictionary], orderDatetime: Date, orderStatusId: Int, comment: String, completionHandler : @escaping (_ result: [NSDictionary], _ error: NSError?) -> Void) {
        
        var paramDict: [[String : Any]] = []
        for item in itemDetails {
            let distUser = item.value(forKey: "dist_user_") as? NSDictionary
            let parameterDict = [
                "id" : item.value(forKey: "id") as? Int as Any,
                "order_status_id": 2,
                "orderby_id" : orderbyId,
                "account_userId" : accountId,
                "parent_userid": distUser?.value(forKey: "parent_userid") as? Int as Any,
                
                "quantity_original" : item.value(forKey: "quantity_original") as? Int as Any,
                "quantity_approved" : item.value(forKey: "quantity_approved") as? Int as Any,
                "quantity_delivered" : item.value(forKey: "quantity_delivered") as? Int as Any,
                
                "price_original": item.value(forKey: "price_original") as? Int as Any,
                "price_delivered": item.value(forKey: "price_delivered") as? Int as Any,
                "price_unit": item.value(forKey: "price_unit") as? String as Any,
                
                "order_datetime": item.value(forKey: "order_datetime") as? String as Any,
                "approved_datetime": item.value(forKey: "approved_datetime") as? String as Any,
                "delivered_datetime": item.value(forKey: "delivered_datetime") as? String as Any,
                
                "dist_frameid": item.value(forKey: "dist_frameid") as? Int as Any,
                "frame_id": item.value(forKey: "frame_id") as? Int as Any,
                "account_frameid": item.value(forKey: "account_frameid") as? Int as Any,
                "comment": comment
                ] as [String : Any]
            paramDict.append(parameterDict)
        }
        
        let parameterJson = JSON(paramDict)
        let parameter = parameterJson.rawString()
        
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]
        
        print(parameter!)
        Alamofire.request(EndPoints().placeDistributorOrder, method: .put, parameters: [:], encoding: parameter!, headers: headers)
            .responseJSON { response in
                var orderDetails: [NSDictionary] = []
                var returnError: NSError?
                
                var userInfo: [AnyHashable : Any] = [:]
                let message: String = "Unknown Error"
                userInfo = [
                    NSLocalizedDescriptionKey : message,
                    NSLocalizedFailureReasonErrorKey : message
                ]
                let unknownError = NSError(domain: EndPoints().placeDistributorOrder, code: 500, userInfo: userInfo)
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    
                    returnError = error as NSError
                    
                case .success(let responseObject):
                    if let result = responseObject as? NSDictionary {
                        if let items = result.value(forKey: "cartList") as? [NSDictionary] {
                            orderDetails = items
                        }
                    } else if let errorResponse = (responseObject as AnyObject).value(forKey: "error") as? NSDictionary {
                        //Error
                        let statusCode = errorResponse.value(forKey: "statusCode") as? Int
                        let message = errorResponse.value(forKey: "message") as? String
                        let userInfo = [
                            NSLocalizedDescriptionKey : message!,
                            NSLocalizedFailureReasonErrorKey : message!
                        ]
                        
                        returnError = NSError(domain: EndPoints().placeDistributorOrder, code: statusCode!, userInfo: userInfo)
                    } else {
                        //Unknown error
                        returnError = unknownError
                    }
                }
                completionHandler(orderDetails, returnError)
        }
    }
    
    
    // MARK: - Favourite functions
    func favInventoryFrames() -> [InventoryFrame] {
        return self.model.favInventoryFrames
    }
    
    func favInventoryFramesCount() -> Int {
        return self.model.favInventoryFrames.count
    }
    
    func addInventoryFrameTofav(_ inventoryFrame: InventoryFrame) -> Bool {
        let shouldBeAdded = !self.isAlreadyAvailbleInfav(inventoryFrame)
        if shouldBeAdded {
            self.model.favInventoryFrames.append(inventoryFrame)
        } else {
            self.model.favInventoryFrames = self.model.favInventoryFrames.filter { $0.uuid != inventoryFrame.uuid }
        }
        return shouldBeAdded
    }
    
    func removeAllInventoryFrameFromfav() {
        self.model.favInventoryFrames.removeAll()
        UserDefaults.standard.set(nil, forKey: "favorites")
    }
    
    func isAlreadyAvailbleInfav(_ inventoryFrame: InventoryFrame) -> Bool {
        var isAlreadyAvailable = false
        
        //Check whether it is already added
        for frame in self.model.favInventoryFrames {
            if frame.uuid == inventoryFrame.uuid {
                isAlreadyAvailable = true
                return isAlreadyAvailable
            }
        }
        return false
    }
}
