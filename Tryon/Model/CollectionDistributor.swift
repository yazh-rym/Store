//
//  CollectionDistributor.swift
//  Tryon
//
//  Created by Udayakumar N on 10/01/18.
//  Copyright © 2018 Adhyas. All rights reserved.
//

import Foundation
import RealmSwift


class CollectionDistributor: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var imageUrl: String?
    @objc dynamic var bannerImageUrl: String?
    @objc dynamic var order: Int = 0
}
