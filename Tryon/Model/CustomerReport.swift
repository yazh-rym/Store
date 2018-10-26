//
//  CustomerReport.swift
//  Tryon
//
//  Created by Udayakumar N on 06/04/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit

struct CustomerSelectedProduct {
    var startTime: Date?
    var endTime: Date?
    var lookzId: String?
}

class CustomerReport: NSObject {
    var deviceID: String
    var startTime: Date?
    var customerType: String?
    var customerMobileNumber: String?
    var customerVideoType: String?
    var customerVideoUrl: String?
    var customerGender: String?
    var customerAge: String?
    var customerFrontalFaceImgUrl: String?
    var customerSelected2DProducts: [CustomerSelectedProduct]?
    var customerSelected3DProducts: [CustomerSelectedProduct]?
    
    override var description: String {
        return descriptionString()
    }
    
    init(deviceID: String) {
        self.deviceID = deviceID
        self.customerSelected2DProducts = []
        self.customerSelected3DProducts = []
    }
    
    func descriptionString() -> String {
        var desc = "\nCustomerReport: deviceID: \(String(describing: deviceID))"
        desc = desc + "\nCustomerReport: startTime: \(String(describing: startTime))"
        desc = desc + "\nCustomerReport: customerType: \(String(describing: customerType))"
        desc = desc + "\nCustomerReport: customerMobileNumber: \(String(describing: customerMobileNumber))"
        desc = desc + "\nCustomerReport: customerVideoType: \(String(describing: customerVideoType))"
        desc = desc + "\nCustomerReport: customerVideoUrl: \(String(describing: customerVideoUrl))"
        desc = desc + "\nCustomerReport: customerGender: \(String(describing: customerGender))"
        desc = desc + "\nCustomerReport: customerAge: \(String(describing: customerAge))"
        desc = desc + "\nCustomerReport: customerFrontalFaceImgUrl: \(String(describing: customerFrontalFaceImgUrl))"
        desc = desc + "\nCustomerReport: customerSelected2DProducts.count: \(String(describing: customerSelected2DProducts?.count))"
        desc = desc + "\nCustomerReport: customerSelected2DProducts: \(String(describing: customerSelected2DProducts))"
        desc = desc + "\nCustomerReport: customerSelected3DProducts.count: \(String(describing: customerSelected3DProducts?.count))"
        desc = desc + "\nCustomerReport: customerSelected3DProducts: \(String(describing: customerSelected3DProducts))"
        
        return desc
    }
    
    func addRender2DToCustomerReport(forLookzId lookzId: String) {
        let customerselected2DProduct = CustomerSelectedProduct(startTime: Date(), endTime: nil, lookzId: lookzId)
        customerSelected2DProducts?.append(customerselected2DProduct)
    }
    
    func updateRender2DToCustomerReport(forLookzId lookzId: String, withEndTime endTime: Date) {
        var index = 0
        for product in customerSelected2DProducts! {
            if product.lookzId == lookzId && product.endTime == nil {
                customerSelected2DProducts?[index].endTime = endTime
                break
            }
            index = index + 1
        }
    }
    
    func addRender3DToCustomerReport(forLookzId lookzId: String) {
        let customerselected3DProduct = CustomerSelectedProduct(startTime: Date(), endTime: nil, lookzId: lookzId)
        customerSelected3DProducts?.append(customerselected3DProduct)
    }
    
    func updateRender3DToCustomerReport(forLookzId lookzId: String, withEndTime endTime: Date) {
        var index = 0
        for product in customerSelected3DProducts! {
            if product.lookzId == lookzId && product.endTime == nil {
                customerSelected3DProducts?[index].endTime = endTime
                break
            }
            index = index + 1
        }
    }
}
