//
//  Customer.swift
//  Tryon
//
//  Created by Udayakumar N on 04/04/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit

enum CustomerType: String {
    case newToGlasses = "NEW"
    case alreadyWearGlasses = "OLD"
}

enum FrameType: String {
    case fullRim = "Fullrim"
    case halfRim = "Halfrim"
    case rimLess = "Rimless"
}

enum Gender: String {
    case male = "M"
    case female = "F"
}

enum AgeGroup: String {
    case child = "<16"
    case young = "16-25"
    case middle = "26-40"
    case old = "40+"
}

enum DrivingType: String {
    case car = "Car"
    case bike = "Bike"
    case both = "Both"
    case noDriving = "None"
}

class Customer: NSObject {
    var imgUrl: String?
    var mobileNumber: String?
    var customerType: CustomerType?
    var frameType: FrameType?
    var drivingType: DrivingType?
    
    override var description: String {
        return descriptionString()
    }
    
    init(imgUrl: String?, mobileNumber: String?, customerType: CustomerType?, frameType: FrameType?, drivingType: DrivingType?) {
        self.imgUrl = imgUrl
        self.mobileNumber = mobileNumber
        self.customerType = customerType
        self.frameType = frameType
        self.drivingType = drivingType
    }
    
    init(imgUrl: String?) {
        self.imgUrl = imgUrl
    }
    
    func descriptionString() -> String {
        var desc = "\nCustomer: imgUrl: \(String(describing: imgUrl))"
        desc = desc + "\nCustomer: mobileNumber: \(String(describing: mobileNumber))"
        desc = desc + "\nCustomer: customerType: \(String(describing: customerType?.rawValue))"
        desc = desc + "\nCustomer: frameType: \(String(describing: frameType?.rawValue))"
        desc = desc + "\nCustomer: drivingType: \(String(describing: drivingType?.rawValue))"
        
        return desc
    }
}
