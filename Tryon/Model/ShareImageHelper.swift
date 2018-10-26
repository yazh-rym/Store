//
//  ShareImageHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 14/06/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import Alamofire

class ShareImageHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    // MARK: - Function to share
    //Function to share image and mobile number
    func shareImage(mobileNumber: String, sourceUrl: String, completionHandler : @escaping (_ error: NSError?) -> Void) {
        
        let params: Parameters = ["callFor" : "sms",
                                  "mobile" : mobileNumber,
                                  "sourceUrl" : sourceUrl]
        
        Alamofire.request(EndPoints().shareImageUrl, method: .get, parameters: params)
            .responseJSON { response in
                var error: NSError?
                
                if response.result.isSuccess {
                    let responseDict = response.result.value as! NSDictionary
                    
                    if responseDict.value(forKey: "status") as! String == "success" || responseDict.value(forKey: "status") as! String == "OK" {
                        //Do nothing
                        log.info("ShareImage - Successfully share image")
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
                        error = NSError(domain: EndPoints().shareImageUrl, code: 500, userInfo: userInfo)
                    }
                } else {
                    error = response.error! as NSError
                }
                completionHandler(error)
        }
    }
}
