//
//  FeaturedData.swift
//  Tryon
//
//  Created by Udayakumar N on 26/10/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit


enum FeaturedCellType: String {
    case featured = "featured"
    case text = "text"
    case rectImage = "rectImage"
    case squareImage = "squareImage"
    case userWithGlass = "userWithGlass"
}

class FeaturedData: NSObject {
    var title: String?
    var isSeeAllVisible: Bool = false
    
    var cellType: FeaturedCellType = .featured
    
    var inventoryData: [[String]]? //TODO: Add User, Inventory instead of Url, Title
    var imageData: [String]? //TODO: Add Filter
    var textData: [String]? //TODO: Add Filter
    
    init(title: String?, isSeeAllVisible: Bool, cellType: FeaturedCellType?, inventoryData: [[String]]?, imageData: [String]?, textData: [String]?) {
        guard let title = title, let cellType = cellType else { return }
        
        self.title = title
        self.isSeeAllVisible = isSeeAllVisible
        self.cellType = cellType
        
        if let data = inventoryData {
            self.inventoryData = data
        }

        if let data = imageData {
            self.imageData = data
        }

        if let data = textData {
            self.textData = data
        }
    }
}
