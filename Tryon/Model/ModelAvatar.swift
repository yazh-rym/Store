//
//  ModelAvatar.swift
//  Tryon
//
//  Created by Udayakumar N on 16/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import RealmSwift


class ModelAvatar: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var modelName: String = ""
    @objc dynamic var frontFaceImgUrl: String = ""
    @objc dynamic var jsonUrl: String = ""
    @objc dynamic var serverVideoUrl: String = ""
    @objc dynamic var appVideoUrl: String?
    @objc dynamic var fileName: String = ""
    @objc dynamic var order: Int = 0
    
    @objc dynamic var gender: CategoryGender?
}
