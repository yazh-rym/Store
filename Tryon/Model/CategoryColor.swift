//
//  CategoryColor.swift
//  Tryon
//
//  Created by Udayakumar N on 15/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import RealmSwift


class CategoryColor: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    let colorR = RealmOptional<Int>()
    let colorG = RealmOptional<Int>()
    let colorB = RealmOptional<Int>()
    @objc dynamic var order: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
