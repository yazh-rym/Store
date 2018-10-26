//
//  UserModel.swift
//  Tryon
//
//  Created by look z on 25/07/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import RealmSwift

class UserModel: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var picture: Data? = nil
    
}
