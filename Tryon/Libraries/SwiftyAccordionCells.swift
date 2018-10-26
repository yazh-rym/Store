//
//  SwiftyAccordionCells.swift
//  SwiftyAccordionCells
//
//  Created by Fischer, Justin on 9/24/15.
//  Copyright © 2015 Justin M Fischer. All rights reserved.
//

import Foundation
import AlamofireImage

class SwiftyAccordionCells {
    //Tryon: Removed private for Tryon
    //fileprivate (set) var items = [Item]()
    var items = [Item]()

    class Item {
        var isHidden: Bool
        var value: String
        var isChecked: Bool
        
        //Tryon: Added for Tryon
        var icon: String
        var category: CategoryIdentifiers
        
        init(_ hidden: Bool = true, value: String, checked: Bool = false, icon: String = "", category: CategoryIdentifiers) {
            self.isHidden = hidden
            self.value = value
            self.isChecked = checked
            self.icon = icon
            self.category = category
        }
    }
    
    class HeaderItem: Item {
        init (value: String, category: CategoryIdentifiers) {
            super.init(false, value: value, checked: false, category: category)
        }
    }
    
    func append(_ item: Item) {
        self.items.append(item)
    }
    
    func removeAll() {
        self.items.removeAll()
    }
    
    func expand(_ headerIndex: Int) {
        self.toogleVisible(headerIndex, isHidden: false)
    }
    
    func collapse(_ headerIndex: Int) {
        self.toogleVisible(headerIndex, isHidden: true)
    }
    
    private func toogleVisible(_ headerIndex: Int, isHidden: Bool) {
        var headerIndex = headerIndex
        headerIndex += 1
        
        while headerIndex < self.items.count && !(self.items[headerIndex] is HeaderItem) {
            self.items[headerIndex].isHidden = isHidden
            
            headerIndex += 1
        }
    }
}
