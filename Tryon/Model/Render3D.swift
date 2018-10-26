//
//  Render3D.swift
//  Tryon
//
//  Created by Udayakumar N on 29/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//


import Foundation


enum Render3DStatus: Int {
    case isNew = 0
    case isFailed
    case isCompleted
}


class Render3D: NSObject {
    var frameId: Int
    var status: Render3DStatus

    init(frameId: Int, status: Render3DStatus = Render3DStatus.isNew) {
        self.frameId = frameId
        self.status = status
    }
}
