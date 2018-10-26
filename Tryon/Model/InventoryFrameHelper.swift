//
//  InventoryFrameHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 13/12/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift


class InventoryFrameHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    
    // MARK: - Filter Inventory data
    func getInventoryFrameObject(fromObject frame: NSDictionary) -> InventoryFrame {
        
        let realm = try! Realm()
        
        //Get ID
        let id = frame.value(forKey: "id") as! Int
        
        //Get Category details
//        let categoryDetails = frame.value(forKey: "category_") as? NSDictionary
//        let categoryId = categoryDetails?.value(forKey: "id") as! Int
        let categoryId = frame.value(forKey: "category_Id") as! Int

        let category = realm.objects(CategoryProductType.self).filter("id in {\(categoryId)}").first
        
        //Get frame type details
//        let frameTypeDetails = frame.value(forKey: "frametype_") as? NSDictionary
//        let frameTypeId = frameTypeDetails?.value(forKey: "id") as! Int
        let frameTypeId = frame.value(forKey: "frametype_Id") as! Int

        let frameType = realm.objects(CategoryFrameType.self).filter("id in {\(frameTypeId)}").first
        
        //Get brand details
//        let brandDetails = frame.value(forKey: "brand_") as? NSDictionary
//        let brandId = brandDetails?.value(forKey: "id") as! Int
        let brandId = frame.value(forKey: "brand_Id") as! Int
        let brand = realm.objects(CategoryBrand.self).filter("id in {\(brandId)}").first
        
        //Get shape details
//        let shapeDetails = frame.value(forKey: "shape_") as? NSDictionary
//        let shapeId = shapeDetails?.value(forKey: "id") as! Int
        let shapeId = frame.value(forKey: "shape_Id") as! Int
        
        let shape = realm.objects(CategoryShape.self).filter("id in {\(shapeId)}").first
        
        //Get Color details
//        let frameColorDetails = frame.value(forKey: "frame_color_") as? NSDictionary
//        let frameColorId = frameColorDetails?.value(forKey: "id") as! Int

        let frameColorId = frame.value(forKey: "frame_color_Id") as! Int
        let frameColor = realm.objects(CategoryColor.self).filter("id in {\(frameColorId)}").first
        
//        let templeColorDetails = frame.value(forKey: "temple_color_") as? NSDictionary
//        let templeColorId = templeColorDetails?.value(forKey: "id") as! Int
        let templeColorId = frame.value(forKey: "temple_color_Id") as! Int
        let templeColor = realm.objects(CategoryColor.self).filter("id in {\(templeColorId)}").first
        
//        let glassColorDetails = frame.value(forKey: "glass_color_") as? NSDictionary
//        let glassColorId = glassColorDetails?.value(forKey: "id") as! Int
        
        let glassColorId = frame.value(forKey: "glass_color_Id") as! Int
        let glassColor = realm.objects(CategoryColor.self).filter("id in {\(glassColorId)}").first
        
        let displayFrameColorText = frame.value(forKey: "display_framecolor_text") as? String
        let displayTempleColorText = frame.value(forKey: "display_templecolor_text") as? String
        let displayGlassColorText = frame.value(forKey: "display_glasscolor_text") as? String
        
        //Get Material details
//        let frameMaterialDetails = frame.value(forKey: "frame_material_") as? NSDictionary
//        let frameMaterialId = frameMaterialDetails?.value(forKey: "id") as! Int
        
        let frameMaterialId = frame.value(forKey: "frame_material_id") as! Int
        let frameMaterial = realm.objects(CategoryMaterial.self).filter("id in {\(frameMaterialId)}").first
        
        let templeMaterialId = frame.value(forKey: "temple_material_Id") as! Int
        let templeMaterial = realm.objects(CategoryMaterial.self).filter("id in {\(templeMaterialId)}").first
        
        let displayMaterialText = frame.value(forKey: "display_material_text") as? String
        
        //Get Gender details
//        let genderDetails = frame.value(forKey: "gender_") as? NSDictionary
//        let genderId = genderDetails?.value(forKey: "id") as! Int
         let genderId = frame.value(forKey: "gender_Id") as! Int
        let gender = realm.objects(CategoryGender.self).filter("id in {\(genderId)}").first
        
        //Get other details
        let lookzId = frame.value(forKey: "lookz_id") as? String
        let modelNumber = frame.value(forKey: "model_number") as? String
        let productName = frame.value(forKey: "product_name") as? String
        let productDescription = frame.value(forKey: "description") as? String
        let priceDistributor = frame.value(forKey: "distributor_price") as? Int// added
        let price = frame.value(forKey: "price") as? Int
        let priceUnit = frame.value(forKey: "price_unit") as? String
        let sizeText = frame.value(forKey: "size") as? String
        let sizeActual = frame.value(forKey: "size_actual") as? String
        let weight = frame.value(forKey: "weight") as? String
        let weightInGrams = frame.value(forKey: "weight_actual_grams") as? Int
        let parentFrameId = frame.value(forKey: "parent_frameId") as? Int
        let internalId = frame.value(forKey: "internal_id") as? String

        //TODO: Do not hard code it to is3DCreatedBool

        var is3DCreated = false
        let is3DCreatedBool = frame.value(forKey: "is_3DCreated") as? Int ?? 0
        if is3DCreatedBool == 0 {
            is3DCreated = false
        } else {
            is3DCreated = true
        }
        
        var isTryonCreated = false
        let isTryonCreatedBool = frame.value(forKey: "is_tryonCreated") as? Int ?? 0
        if isTryonCreatedBool == 0 {
            isTryonCreated = false
        } else {
            isTryonCreated = true
        }
        
        let imagePath = frame.value(forKey: "image_path") as? String
        
        //TODO: Hardcoded for testing
        let uuid = lookzId!

//        let uuid = frame.value(forKey: "uuid") as? String

        var thumbnailImageUrl: String = ""
        if is3DCreated {
            thumbnailImageUrl = imagePath! + uuid + "/360degree/Low/thumbnail.jpg"
        } else {
            thumbnailImageUrl = imagePath! + uuid + "/thumbnail.jpg"
        }
        
        let inventoryFrame = InventoryFrame(value: ["id": id, "uuid": uuid as Any, "category": category as Any, "frameType": frameType as Any, "brand": brand as Any, "shape": shape as Any, "frameColor": frameColor as Any, "templeColor": templeColor as Any, "glassColor": glassColor as Any, "displayFrameColorText": displayFrameColorText as Any, "displayTempleColorText": displayTempleColorText as Any, "displayGlassColorText": displayGlassColorText as Any, "frameMaterial": frameMaterial as Any, "templeMaterial": templeMaterial as Any, "displayMaterialText": displayMaterialText as Any, "gender": gender as Any, "modelNumber": modelNumber as Any, "productName": productName as Any, "productDescription": productDescription as Any, "priceDistributor": priceDistributor as Any,"price": price as Any, "priceUnit": priceUnit as Any, "sizeText": sizeText as Any, "sizeActual": sizeActual as Any, "weight": weight as Any, "weightInGrams": weightInGrams as Any, "parentFrameId": parentFrameId as Any, "internalId": internalId as Any, "is3DCreated": is3DCreatedBool, "isTryonCreated": isTryonCreatedBool, "imagePath": imagePath as Any, "thumbnailImageUrl": thumbnailImageUrl, "lookzId": lookzId as Any])
        
        return inventoryFrame
    }
    
    func searchInventory(searchString: String, completionHandler : @escaping (_ result: [InventoryFrame], NSError?) -> Void) {
        let realm = try! Realm()
        var inventoryFrames: [InventoryFrame] = []
        
        var filterString = "category.name CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or frameType.name CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or brand.name CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or shape.name CONTAINS[cd] '\(searchString)'"
        
        filterString = filterString + " or frameColor.name CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or templeColor.name CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or glassColor.name CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or displayFrameColorText CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or displayTempleColorText CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or displayGlassColorText CONTAINS[cd] '\(searchString)'"
        
        filterString = filterString + " or frameMaterial.name CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or templeMaterial.name CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or displayMaterialText CONTAINS[cd] '\(searchString)'"

        filterString = filterString + " or gender.name CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or modelNumber CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or productDescription CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or sizeText CONTAINS[cd] '\(searchString)'"
        filterString = filterString + " or sizeActual CONTAINS[cd] '\(searchString)'"
        
        if searchString.uppercased() == "3D" {
            filterString = filterString + " or is3DCreated == true"
        } else if searchString.uppercased() == "2D" {
            filterString = filterString + " or is3DCreated == false"
        } else if searchString.uppercased() == "TRYON" {
            filterString = filterString + " or isTryonCreated == true"
        }
        
        let result: Results<InventoryFrame> = realm.objects(InventoryFrame.self).filter(filterString)
        
        for frame in result {
            if let parentId = frame.parentFrameId.value {
                if inventoryFrames.filter({ existingFrame in existingFrame.id == parentId }).count > 0 {
                    //My Parent is already present
                    continue
                    
                } else if inventoryFrames.filter({ existingFrame in existingFrame.parentFrameId.value == frame.id }).count > 0 {
                    //My child is already present
                    continue
                    
                } else if (frame.parentFrameId.value != nil) && inventoryFrames.filter({ existingFrame in existingFrame.parentFrameId.value == parentId }).count > 0 {
                    //My sibling is already present
                    continue
                    
                } else {
                    inventoryFrames.append(frame)
                }
                
            } else {
                inventoryFrames.append(frame)
            }
        }

        completionHandler(inventoryFrames, nil)
    }
    
    func filterInventory(filterList: [FilterList: [Int]], additionalFilterString: String?, completionHandler : @escaping (_ result: [InventoryFrame], NSError?) -> Void) {
        let realm = try! Realm()
        var filterString: String?
        var inventoryFrames: [InventoryFrame] = []
        
        for filter in filterList.keys {
            switch filter {
            case .productType:
                if filterString != nil {
                    filterString = filterString! + " and " + "category.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                } else {
                    filterString = "category.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                }
            case .gender:
                if filterString != nil {
                    filterString = filterString! + " and " + "gender.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                } else {
                    filterString = "gender.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                }
            case .frameType:
                if filterString != nil {
                    filterString = filterString! + " and " + "frameType.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                } else {
                    filterString = "frameType.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                }
            case .shape:
                if filterString != nil {
                    filterString = filterString! + " and " + "shape.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                } else {
                    filterString = "shape.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                }
            case .brand:
                if filterString != nil {
                    filterString = filterString! + " and " + "brand.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                } else {
                    filterString = "brand.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                }
                
            case .color:
                if filterString != nil {
                    filterString = filterString! + " and (" + "frameColor.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                    filterString = filterString! + " or " + "templeColor.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                    filterString = filterString! + " or " + "glassColor.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}" + ")"
                } else {
                    filterString = "frameColor.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                    filterString = filterString! + " or " + "templeColor.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                    filterString = filterString! + " or " + "glassColor.id in {" + filterList[filter]!.map({"\($0)"}).joined(separator: ",") + "}"
                }
            }
        }
        
        //Add any additional filters, if any
        if let additionalFilter = additionalFilterString {
            if filterString != nil {
                filterString = "(" + filterString! + ")" + additionalFilter
            } else {
                filterString = additionalFilter
            }
        }
        
        var result: Results<InventoryFrame>
        if let filter = filterString {
            result = realm.objects(InventoryFrame.self).filter(filter)
        } else {
            result = realm.objects(InventoryFrame.self)
        }
        
        for frame in result {
            if let parentId = frame.parentFrameId.value {
                if inventoryFrames.filter({ existingFrame in existingFrame.id == parentId }).count > 0 {
                    //My Parent is already present
                    continue
                    
                } else if inventoryFrames.filter({ existingFrame in existingFrame.parentFrameId.value == frame.id }).count > 0 {
                    //My child is already present
                    continue
                    
                } else if (frame.parentFrameId.value != nil) && inventoryFrames.filter({ existingFrame in existingFrame.parentFrameId.value == parentId }).count > 0 {
                    //My sibling is already present
                    continue
                    
                } else {
                    inventoryFrames.append(frame)
                }

            } else {
                inventoryFrames.append(frame)
            }
        }
        
        completionHandler(inventoryFrames, nil)
    }
    
    func getAllInventories(completionHandler : @escaping (_ result: [InventoryFrame], NSError?) -> Void) {
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]
        
        Alamofire.request(EndPoints().getInventoryUrl, method: .get, parameters: nil, headers: headers)
            .responseJSON { response in
                var inventoryFrames: [InventoryFrame] = []
                var error: NSError?
                
                var userInfo: [AnyHashable : Any] = [:]
                let message: String = "Unknown Error"
                userInfo = [
                    NSLocalizedDescriptionKey : message,
                    NSLocalizedFailureReasonErrorKey : message
                ]
                let unknownError = NSError(domain: EndPoints().getInventoryUrl, code: 500, userInfo: userInfo)
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    
                    completionHandler(inventoryFrames, error as NSError)
                    
                case .success(let responseObject):
                    if let frames = responseObject as? [NSDictionary] {
                        for frame in frames {
                            let inventoryFrame = self.getInventoryFrameObject(fromObject: frame)
                            inventoryFrames.append(inventoryFrame)
                        }
                    } else if let errorResponse = (responseObject as AnyObject).value(forKey: "error") as? NSDictionary {
                        //Error
                        let statusCode = errorResponse.value(forKey: "statusCode") as? Int
                        let message = errorResponse.value(forKey: "message") as? String
                        let userInfo = [
                            NSLocalizedDescriptionKey : message!,
                            NSLocalizedFailureReasonErrorKey : message!
                        ]
                        
                        error = NSError(domain: EndPoints().getInventoryUrl, code: statusCode!, userInfo: userInfo)
                    } else {
                        //Unknown error
                        error = unknownError
                    }
                    
                    //Identify dominant color
                    let masterFrames = inventoryFrames.filter { $0.parentFrameId.value == nil }
                    for masterFrame in masterFrames {
                        var childFrames = inventoryFrames.filter { $0.parentFrameId.value == masterFrame.id }
                        
                        for child in childFrames {
                            masterFrame.childFrames.append(child)
                        }
                        
                        childFrames.append(masterFrame)
                        
                        if childFrames.count > 1 {
                            for frameFromGroup in childFrames {
                                var frameColorCount = 0
                                var templeColorCount = 0
                                var glassColorCount = 0
                                
                                for frame in childFrames {
                                    if frameFromGroup.frameColor?.id == frame.frameColor?.id {
                                        frameColorCount = frameColorCount + 1
                                    }
                                    
                                    if frameFromGroup.templeColor?.id == frame.templeColor?.id {
                                        templeColorCount = templeColorCount + 1
                                    }
                                    
                                    if frameFromGroup.glassColor?.id == frame.glassColor?.id {
                                        glassColorCount = glassColorCount + 1
                                    }
                                }
                                
                                if frameColorCount <= templeColorCount && frameColorCount <= glassColorCount {
                                    frameFromGroup.identifiedColor = frameFromGroup.frameColor
                                } else if templeColorCount <= frameColorCount && templeColorCount <= glassColorCount {
                                    frameFromGroup.identifiedColor = frameFromGroup.templeColor
                                } else {
                                    frameFromGroup.identifiedColor = frameFromGroup.glassColor
                                }
                            }
                        }
                    }
                    
                    completionHandler(inventoryFrames, error)
                }
        }
    }
}
