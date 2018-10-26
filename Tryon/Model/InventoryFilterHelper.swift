//
//  InventoryFilterHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 27/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import Alamofire

class InventoryFilterHelper: NSObject {

    // MARK: - Class variables
    
    static let model = TryonModel.sharedInstance
    
    
    // MARK: - Filter Inventory data
    
    func filterInventory(allFilters: [String: [String]], rangeFilters: [String : Dictionary<String, Double?>]?, page: Int, completionHandler : @escaping (_ result: [Inventory], _ page: Int, _ totalInventoryCount: Int, NSError?) -> Void) {
                
        //Update Gender filter
        var allFiltersUpdated = allFilters
        var genderLetterArray = [String]()
        if let genderFilter = allFilters[CategoryIdentifiers.gender.rawValue] as [String]? {
            for filter in genderFilter {
                if let letter = filter.characters.first {
                    genderLetterArray.append(String(letter))
                }
            }
            allFiltersUpdated[CategoryIdentifiers.gender.rawValue] = genderLetterArray
        }
        
        //Add Price range filter
        var filters: [String: Any] = allFiltersUpdated
        if (rangeFilters != nil) {
            filters[CategoryIdentifiers.price.rawValue] = rangeFilters?[CategoryIdentifiers.price.rawValue]
        }
        
        //Change params to json
        let filterDict = ["device_id" : InventoryFilterHelper.model.deviceId, "filter" : filters, "page": page] as [String : Any]
        var filterString: String = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: filterDict)
            if let filter = String(data: jsonData, encoding: String.Encoding.utf8) {
                filterString = filter
            }
        } catch {
            completionHandler([], page, 0, error as NSError)
        }
        
        let headers = ["Content-Type": "application/json"]
        Alamofire.request(EndPoints().getInventoryUrl, method: .post, parameters: [:], encoding: filterString, headers: headers)
            .responseJSON { response in
                
                var inventories = [Inventory]()
                var totalInventoryCount: Int?
                var error: NSError?
                
                if response.result.isSuccess {
                    let responseDict = response.result.value as! NSDictionary
                    if responseDict.value(forKey: "status") as! String == "success" || responseDict.value(forKey: "status") as! String == "OK" {
                        if let dataDict1 = responseDict.value(forKey: "data") as! NSDictionary? {
                            if let dataDict2 = dataDict1.value(forKey: "hits") as! NSDictionary? {
                                totalInventoryCount = dataDict2.value(forKey: "total") as! Int?

                                if let dataArray = dataDict2.value(forKey: "hits") as! NSArray? {
                                    for data in dataArray {
                                        if let inventoryDict = (data as! NSDictionary).value(forKey: "_source") as! NSDictionary? {
                                            let id = (data as! NSDictionary).value(forKey: "_id") as! String?
                                            let category = inventoryDict.value(forKey: "category") as! String?
                                            let description = inventoryDict.value(forKey: "description") as! String?
                                            let frameBrand = inventoryDict.value(forKey: "frame_brand") as! String?
                                            let frameColor = inventoryDict.value(forKey: "frame_color") as! String?
                                            let frameMaterial = inventoryDict.value(forKey: "frame_material") as! String?
                                            let frameShape = inventoryDict.value(forKey: "frame_shape") as! String?
                                            let frameType = inventoryDict.value(forKey: "frame_type") as! String?
                                            let gender = inventoryDict.value(forKey: "gender") as! String?
                                            let name = inventoryDict.value(forKey: "name") as! String?
                                            let price = inventoryDict.value(forKey: "price") as! Int?
                                            let size = inventoryDict.value(forKey: "size") as! String?
                                            let productId = inventoryDict.value(forKey: "product_id") as! String?
                                            let productName = inventoryDict.value(forKey: "product_name") as! String?
                                            let imgUrls = inventoryDict.value(forKey: "img") as! [String]?
                                            let thumbNailImageUrl = inventoryDict.value(forKey: "thumbnail") as! String?
                                            
                                            let inventory = Inventory(id: id, name: name, productId: productId, productName: productName, inventoryDescription: description, frameCategory: category, frameBrand: frameBrand, frameColor: frameColor, frameMaterial: frameMaterial, frameShape: frameShape, frameType: frameType, gender: gender, price: price, size: size, imgUrls: imgUrls, thumbNailImageUrl: thumbNailImageUrl)
                                            inventories.append(inventory)
                                        }
                                    }
                                }
                            }
                        }
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
                        error = NSError(domain: EndPoints().getInventoryUrl, code: 500, userInfo: userInfo)
                    }
                } else {
                    error = response.error! as NSError
                }
                completionHandler(inventories, page, totalInventoryCount ?? 0, error)
        }
    }
}
