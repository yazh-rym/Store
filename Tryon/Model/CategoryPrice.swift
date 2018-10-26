//
//  CategoryPrice.swift
//  Tryon
//
//  Created by Udayakumar N on 16/06/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import RealmSwift


class CategoryPrice: Object {
    @objc dynamic var maxValue: Double = 0.0
    @objc dynamic var minValue: Double = 0.0
    
//    override func isEqual(_ object: Any?) -> Bool {
//        if let object = object as? CategoryPrice {
//            return maxValue == object.maxValue && minValue == object.minValue
//        } else {
//            return false
//        }
//    }
}
