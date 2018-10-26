//
//  UserLiked.swift
//  Tryon
//
//  Created by Udayakumar N on 27/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation

class UserLiked: NSObject {
    
    // MARK: - Class variables
    var frame: InventoryFrame
    var render3D: Render3D
    let model = TryonModel.sharedInstance
    
    init(frame: InventoryFrame) {
        self.frame = frame
        self.render3D = Render3D(frameId: frame.id)
    }
    
    // MARK: - Description
    override var description: String {
        return descriptionString()
    }
    
    func descriptionString() -> String {
        var desc = "\nUserLiked: frame:\n\(String(describing: frame.description))"
        desc = desc + "\nUserLiked: render3D:\n\(String(describing: render3D.description))"
        
        return desc
    }
}
