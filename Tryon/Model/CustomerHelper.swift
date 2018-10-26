//
//  CustomerHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 04/04/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import Alamofire

class CustomerHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    
    // MARK: - Customer
    func updateCustomerDetails(completionHandler : @escaping (_ error: NSError?) -> Void) {
        
        //Change params to json
        let filterDict = ["device_id" : CustomerHelper().model.deviceId,
                          "center_image" : CustomerHelper().model.customer?.imgUrl ?? "",
                          "mobile_no" : CustomerHelper().model.customer?.mobileNumber ?? "",
                          "userType" : CustomerHelper().model.customer?.customerType?.rawValue ?? "",
                          "frameType" : CustomerHelper().model.customer?.frameType?.rawValue ?? "",
                          "drivingType": CustomerHelper().model.customer?.drivingType?.rawValue ?? ""] as [String : Any]
        var filterString: String = ""
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: filterDict)
            if let filter = String(data: jsonData, encoding: String.Encoding.utf8) {
                filterString = filter
            }
        } catch {
            completionHandler(error as NSError)
        }
        
        let headers = ["Content-Type": "application/json"]
        Alamofire.request(EndPoints().updateCustomerDetails, method: .post, parameters: [:], encoding: filterString, headers: headers)
            .responseJSON { response in
                
                var error: NSError?
                
                if response.result.isSuccess {
                    let responseDict = response.result.value as! NSDictionary
                    if responseDict.value(forKey: "status") as! String == "success" || responseDict.value(forKey: "status") as! String == "OK" {
                        log.info("Customer Details updated Successfully")
                    }
                    else {
                        var userInfo: [AnyHashable : Any] = [:]
                        var message: String = "Unknown Error"
                        
                        if let messageFromServer = responseDict.value(forKey: "message") as! String? {
                            message = messageFromServer
                        }
                        
                        userInfo = [
                            NSLocalizedDescriptionKey : message,
                            NSLocalizedFailureReasonErrorKey : message
                        ]
                        error = NSError(domain: EndPoints().updateCustomerDetails, code: 500, userInfo: userInfo)
                        log.error("Customer Details update - Failed with error: \(String(describing: error))")
                    }
                } else {
                    error = response.error! as NSError
                    log.error("Customer Details update - Failed with error: \(String(describing: error))")
                }
                completionHandler(error)
        }
    }
}
