//
//  BuyHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 10/10/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import Foundation
import Alamofire

class BuyHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    // MARK: - Function to share
    //Function to send sms when buy button is tapped
    func sendSms(mobileNumber: String, frame: InventoryFrame, completionHandler : @escaping (_ error: NSError?) -> Void) {
        
        let counterAdminMobileNumber = "8667444080,7259163927" //Mani and Veera
        var message = mobileNumber + "\n" + String(frame.id) + "\n"

        if let name = frame.productName {
            message = message + name + "\n"
        }
        if let type = frame.frameType {
            message = message + type.name + "\n"
        }
        if let color = frame.frameColor {
            message = message + color.name + "\n"
        }
        if let size = frame.size {
            message = message + size + "\n"
        }
//        if let price = frame.price {
//            message = message + "Rs." + String(price)
//        }
        
        let params: Parameters = ["receipientno" : counterAdminMobileNumber,
                                  "msgtxt" : message]
        
        Alamofire.request(EndPoints().smsUrl, method: .get, parameters: params)
            .responseJSON { response in
                var error: NSError?
                
                let responseString = String(data: response.data!, encoding: String.Encoding.utf8)
                if (responseString?.contains("success"))! {
                    log.info("BuySMS - Successful")
                } else {
                    var userInfo: [AnyHashable : Any] = [:]
                    let message: String = responseString!
                    
                    userInfo = [
                        NSLocalizedDescriptionKey : message,
                        NSLocalizedFailureReasonErrorKey : message
                    ]
                    error = NSError(domain: EndPoints().smsUrl, code: 500, userInfo: userInfo)
                }
                completionHandler(error)
        }
    }
}
