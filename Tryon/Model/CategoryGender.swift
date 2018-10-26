//
//  CategoryGender.swift
//  Tryon
//
//  Created by Udayakumar N on 15/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import RealmSwift


class CategoryGender: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var iconUrl: String?
    @objc dynamic var order: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
