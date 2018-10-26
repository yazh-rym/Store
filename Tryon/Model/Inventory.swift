//
//  Inventory.swift
//  Tryon
//
//  Created by Udayakumar N on 15/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation

class Inventory: NSObject {
    var id: String?
    var name: String?
    var productId: String?
    var productName: String?
    var inventoryDescription: String?
    var frameCategory: String?
    var frameBrand: String?
    var frameColor: String?
    var frameMaterial: String?
    var frameShape: String?
    var frameType: String?
    var gender: String?
    var price: Int?
    var size: String?
    var imgUrls: [String]?
    var thumbNailImageUrl: String?
    var isSelected: Bool = false
    
    override var description: String {
        return descriptionString()
    }
    
    init(id: String?, name: String?, productId: String?, productName: String?, inventoryDescription: String?, frameCategory: String?, frameBrand: String?, frameColor: String?, frameMaterial: String?, frameShape: String?, frameType: String?, gender: String?, price: Int?, size: String?, imgUrls: [String]?, thumbNailImageUrl: String?) {
        self.id = id
        self.name = name
        self.productId = productId
        self.productName = productName
        self.inventoryDescription = inventoryDescription
        self.frameCategory = frameCategory
        self.frameBrand = frameBrand
        self.frameColor = frameColor
        self.frameMaterial = frameMaterial
        self.frameShape = frameShape
        self.frameType = frameType
        self.gender = gender
        self.price = price
        self.size = size
        self.imgUrls = imgUrls
        self.thumbNailImageUrl = thumbNailImageUrl
    }
    
    func descriptionString() -> String {
        var desc = "\nInventory: id: \(String(describing: id))"
        desc = desc + "\nInventory: name: \(String(describing: name))"
        desc = desc + "\nInventory: productId: \(String(describing: productId))"
        desc = desc + "\nInventory: productName: \(String(describing: productName))"
        desc = desc + "\nInventory: inventoryDescription: \(String(describing: inventoryDescription))"
        desc = desc + "\nInventory: frameCategory: \(String(describing: frameCategory))"
        desc = desc + "\nInventory: frameBrand: \(String(describing: frameBrand))"
        desc = desc + "\nInventory: frameColor: \(String(describing: frameColor))"
        desc = desc + "\nInventory: frameMaterial: \(String(describing: frameMaterial))"
        desc = desc + "\nInventory: frameShape: \(String(describing: frameShape))"
        desc = desc + "\nInventory: frameType: \(String(describing: frameType))"
        desc = desc + "\nInventory: gender: \(String(describing: gender))"
        desc = desc + "\nInventory: price: \(String(describing: price))"
        desc = desc + "\nInventory: Size: \(String(describing: size))"
        desc = desc + "\nInventory: imgUrls.count: \(String(describing: imgUrls?.count))"
        desc = desc + "\nInventory: imgUrls: \(String(describing: imgUrls))"
        desc = desc + "\nInventory: thumbNailImageUrl: \(String(describing: thumbNailImageUrl))"
        desc = desc + "\nInventory: isSelected: \(String(describing: isSelected))"
        
        return desc
    }
}
