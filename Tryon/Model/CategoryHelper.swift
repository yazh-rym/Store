//
//  CategoryHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 15/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

enum CategoryIdentifiers: String {
    case productType = "categories"
    case frameType = "frametypes"
    case brand = "brands"
    case shape = "shapes"
    case color = "colors"
    case gender = "genders"
}

class CategoryHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    
    // MARK: - Get Category data
    func getAllCategories(completionHandler : @escaping (_ result: Bool) -> Void) {
        var isProductTypeLoaded = false
        var isBrandLoaded = false
        var isShapeLoaded = false
        var isFrameTypeLoaded = false
        var isGenderLoaded = false
        var isColorLoaded = false
        
        self.getCategoryProductType { (productTypes) in
            isProductTypeLoaded = true
        
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CategoryProductType.self))
                for product in productTypes {
                    realm.add(product)
                }
            }
 
            if isProductTypeLoaded && isBrandLoaded && isShapeLoaded && isFrameTypeLoaded && isGenderLoaded && isColorLoaded {
                completionHandler(true)
            }
        }
        
        self.getCategoryBrand { (brands) in
            isBrandLoaded = true
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CategoryBrand.self))
                for brand in brands {
                    realm.add(brand)
                }
            }
            
            if isProductTypeLoaded && isBrandLoaded && isShapeLoaded && isFrameTypeLoaded && isGenderLoaded && isColorLoaded {
                completionHandler(true)
            }
        }
        
        self.getCategoryShape { (shapes) in
            isShapeLoaded = true
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CategoryShape.self))
                for shape in shapes {
                    realm.add(shape)
                }
            }
            
            if isProductTypeLoaded && isBrandLoaded && isShapeLoaded && isFrameTypeLoaded && isGenderLoaded && isColorLoaded {
                completionHandler(true)
            }
        }
        
        self.getCategoryFrameType { (frameTypes) in
            isFrameTypeLoaded = true
       
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CategoryFrameType.self))
                for frame in frameTypes {
                    realm.add(frame)
                }
            }

            if isProductTypeLoaded && isBrandLoaded && isShapeLoaded && isFrameTypeLoaded && isGenderLoaded && isColorLoaded {
                completionHandler(true)
            }
        }
        
        self.getCategoryColor { (colors) in
            isColorLoaded = true

            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CategoryColor.self))
                for color in colors {
                    realm.add(color)
                }
            }

            if isProductTypeLoaded && isBrandLoaded && isShapeLoaded && isFrameTypeLoaded && isGenderLoaded && isColorLoaded {
                completionHandler(true)
            }
        }
        
        self.getCategoryGender { (genders) in
            isGenderLoaded = true
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(realm.objects(CategoryGender.self))
                for gender in genders {
                    realm.add(gender)
                }
            }
            
            if isProductTypeLoaded && isBrandLoaded && isShapeLoaded && isFrameTypeLoaded && isGenderLoaded && isColorLoaded {
                completionHandler(true)
            }
        }
    }

    func getCategoryProductType(completionHandler : @escaping (_ result: [CategoryProductType]) -> Void) {
        getCategory(forCategory: CategoryIdentifiers.productType.rawValue, completionHandler: { (dataArray, error) -> () in
            var categoryProductTypes: [CategoryProductType] = []
            for dataDict in dataArray {
                let id = dataDict.value(forKey: "id") as! Int
                let name = dataDict.value(forKey: "category") as! String
                let iconUrl = dataDict.value(forKey: "category_icon_url") as? String
                let order = dataDict.value(forKey: "order") as! Int

                let categoryProductType = CategoryProductType(value: ["id" : id, "name" : name, "iconUrl" : iconUrl as Any, "order" : order])
                categoryProductTypes.append(categoryProductType)
            }
            completionHandler(categoryProductTypes)
        })
    }
    
    func getCategoryBrand(completionHandler : @escaping (_ result: [CategoryBrand]) -> Void) {
        getCategory(forCategory: CategoryIdentifiers.brand.rawValue, completionHandler: { (dataArray, error) -> () in
            var categoryBrands: [CategoryBrand] = []
            for dataDict in dataArray {
                let id = dataDict.value(forKey: "id") as! Int
                let name = dataDict.value(forKey: "brand") as! String
                let iconUrl = dataDict.value(forKey: "brand_icon_url") as? String
                let bannerImageUrl = dataDict.value(forKey: "brand_bannerimage_url") as? String
                let order = dataDict.value(forKey: "order") as! Int
                
                let categoryBrand = CategoryBrand(value: ["id" : id, "name" : name, "iconUrl" : iconUrl as Any, "bannerImageUrl" : bannerImageUrl as Any, "order" : order])
                categoryBrands.append(categoryBrand)
            }
            completionHandler(categoryBrands)
        })
    }
    
    func getCategoryShape(completionHandler : @escaping (_ result: [CategoryShape]) -> Void) {
        getCategory(forCategory: CategoryIdentifiers.shape.rawValue, completionHandler: { (dataArray, error) -> () in
            var categoryShapes: [CategoryShape] = []
            for dataDict in dataArray {
                let id = dataDict.value(forKey: "id") as! Int
                let name = dataDict.value(forKey: "shape") as! String
                let iconUrl = dataDict.value(forKey: "shape_icon") as? String
                let order = dataDict.value(forKey: "order") as! Int
                
                let categoryShape = CategoryShape(value: ["id" : id, "name" : name, "iconUrl" : iconUrl as Any, "order" : order])
                categoryShapes.append(categoryShape)
            }
            completionHandler(categoryShapes)
        })
    }

    func getCategoryFrameType(completionHandler : @escaping (_ result: [CategoryFrameType]) -> Void) {
        getCategory(forCategory: CategoryIdentifiers.frameType.rawValue, completionHandler: { (dataArray, error) -> () in
//            let categor = CategoryFrameType(value: ["id" : 4, "name" : "ShellFullRim", "iconUrl" : "https://s3.ap-south-1.amazonaws.com/files.adhyas.com/backend/master/Shape_Square.png" as Any, "order" : 4])
            var categoryFrameTypes: [CategoryFrameType] = []
            for dataDict in dataArray {
                let id = dataDict.value(forKey: "id") as! Int
                let name = dataDict.value(forKey: "frametype") as! String
                let iconUrl = dataDict.value(forKey: "frametype_icon_url") as? String
                let order = dataDict.value(forKey: "order") as! Int
                
                let categoryFrameType = CategoryFrameType(value: ["id" : id, "name" : name, "iconUrl" : iconUrl as Any, "order" : order])
                categoryFrameTypes.append(categoryFrameType)
            }
//        categoryFrameTypes.append(categor)
            completionHandler(categoryFrameTypes)
        })
    }
    
    func getCategoryColor(completionHandler : @escaping (_ result: [CategoryColor]) -> Void) {
        getCategory(forCategory: CategoryIdentifiers.color.rawValue, completionHandler: { (dataArray, error) -> () in
            var categoryColors: [CategoryColor] = []
            for dataDict in dataArray {
                let id = dataDict.value(forKey: "id") as! Int
                let name = dataDict.value(forKey: "color") as! String
                let colorR = dataDict.value(forKey: "color_r") as? Int
                let colorG = dataDict.value(forKey: "color_g") as? Int
                let colorB = dataDict.value(forKey: "color_b") as? Int
                let order = dataDict.value(forKey: "order") as! Int

                let categoryColor = CategoryColor(value: ["id" : id, "name" : name, "colorR" : colorR as Any, "colorG" : colorG as Any, "colorB" : colorB as Any, "order" : order])
                categoryColors.append(categoryColor)
            }
            completionHandler(categoryColors)
        })
    }
    
    func getCategoryGender(completionHandler : @escaping (_ result: [CategoryGender]) -> Void) {
        getCategory(forCategory: CategoryIdentifiers.gender.rawValue, completionHandler: { (dataArray, error) -> () in
            var categoryGenders: [CategoryGender] = []
            for dataDict in dataArray {
                let id = dataDict.value(forKey: "id") as! Int
                let name = dataDict.value(forKey: "gender") as! String
                let iconUrl = dataDict.value(forKey: "gender_icon") as? String
                let order = dataDict.value(forKey: "order") as! Int
                
                let categoryGender = CategoryGender(value: ["id" : id, "name" : name, "iconUrl" : iconUrl as Any, "order" : order])
                categoryGenders.append(categoryGender)
            }
            completionHandler(categoryGenders)
        })
    }
    
    //Get Category data
    func getCategory(forCategory category: String, completionHandler : @escaping (_ result: [NSDictionary], _ error: NSError?) -> Void) {
        let url = EndPoints().baseUrl + category
        
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]

        Alamofire.request(url, method: .get, parameters: [:], headers: headers)
            .responseJSON { response in
                
                var getCategoryUnknownError: NSError?
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    
                    completionHandler([], error as NSError)
                    
                case .success(let responseObject):
                    if let dataArray = responseObject as? [NSDictionary] {
                        completionHandler(dataArray, nil)
                    } else {
                        var userInfo: [AnyHashable : Any] = [:]
                        let message: String = "Unknown Error"
                        
                        userInfo = [
                            NSLocalizedDescriptionKey : message,
                            NSLocalizedFailureReasonErrorKey : message
                        ]
                        getCategoryUnknownError = NSError(domain: url, code: 500, userInfo: userInfo)
                        completionHandler([], getCategoryUnknownError)
                    }
                }
        }
    }
}
