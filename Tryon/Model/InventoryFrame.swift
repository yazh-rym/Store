//
//  InventoryFrame.swift
//  Tryon
//
//  Created by Udayakumar N on 13/12/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import Foundation
import RealmSwift

class InventoryFrame: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var uuid: String = ""
    @objc dynamic var lookzId: String?
    @objc dynamic var category: CategoryProductType?
    @objc dynamic var frameType: CategoryFrameType?
    @objc dynamic var brand: CategoryBrand?
    @objc dynamic var shape: CategoryShape?
    
    @objc dynamic var frameColor: CategoryColor?
    @objc dynamic var templeColor: CategoryColor?
    @objc dynamic var glassColor: CategoryColor?
    @objc dynamic var displayFrameColorText: String?
    @objc dynamic var displayTempleColorText: String?
    @objc dynamic var displayGlassColorText: String?
    
    @objc dynamic var identifiedColor: CategoryColor?
    
    @objc dynamic var frameMaterial: CategoryMaterial?
    @objc dynamic var templeMaterial: CategoryMaterial?
    @objc dynamic var displayMaterialText: String?
    
    @objc dynamic var gender: CategoryGender?
    
    @objc dynamic var modelNumber: String?
    @objc dynamic var productName: String?
    @objc dynamic var productDescription: String?
    
    let priceDistributor = RealmOptional<Double>()

    let price = RealmOptional<Double>()
    @objc dynamic var priceUnit: String?
    @objc dynamic var sizeText: String?
    @objc dynamic var sizeActual: String?
    @objc dynamic var weight: String?
    let weightInGrams = RealmOptional<Int>()
    let parentFrameId = RealmOptional<Int>()
    @objc dynamic var internalId: String?
    
    let childFrames = List<InventoryFrame>()
    let parentFrame = LinkingObjects(fromType: InventoryFrame.self, property: "childFrames")
    
    @objc dynamic var thumbnailImageUrl: String?
    @objc dynamic var isSelected: Bool = false

    @objc dynamic var is3DCreated: Bool = false
    @objc dynamic var isTryonCreated: Bool = false
    
    @objc dynamic var imagePath: String?
    
    @objc dynamic var orderQuantityCount: Int = 1
}
