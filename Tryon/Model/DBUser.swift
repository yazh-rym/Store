//
//  DBUser.swift
//  Tryon
//
//  Created by Udayakumar N on 30/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import Foundation
import RealmSwift

class DBUser: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var address1: String?
    @objc dynamic var address2: String?
    @objc dynamic var district: String?
    @objc dynamic var state: String?
    @objc dynamic var pincode: String?
//    @objc dynamic var logourl: String?
//    @objc dynamic var username: String?
//    @objc dynamic var userTypeId: String?
//    @objc dynamic var email: String?
}
