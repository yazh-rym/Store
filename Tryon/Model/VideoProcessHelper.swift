//
//  VideoProcessHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 22/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Alamofire

class VideoProcessHelper: NSObject {
    
    //Function to get user data
    func processVideo(videoURL: String, completionHandler : @escaping (_ result: NSDictionary?, _ error: NSError?) -> Void) {
        let params: Parameters = ["videoURL" : videoURL]
        
        Alamofire.request(EndPoints().processVideoUrl, method: .get, parameters: params)
            .responseJSON { response in
                var result: NSDictionary?
                var error: NSError?
                
                if response.result.isSuccess {
                    let responseDict = response.result.value as! NSDictionary
                    
                    if responseDict.value(forKey: "status") as! String == "success" || responseDict.value(forKey: "status") as! String == "OK" {
                        result = responseDict
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
                        error = NSError(domain: EndPoints().processVideoUrl, code: 500, userInfo: userInfo)
                    }
                } else {
                    error = response.error! as NSError
                }
                completionHandler(result, error)
        }
    }
}
