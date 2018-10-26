//
//  UrlShortenerHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 08/06/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import Alamofire


class UrlShortenerHelper: NSObject {
        
    //Function to get short url
    func getShortUrl(longUrl: String, completionHandler : @escaping (_ shortUrl: String?, _ error: NSError?) -> Void) {
        
        let params: Parameters = ["longUrl" : longUrl]
        
        var paramString: String = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params)
            if let param = String(data: jsonData, encoding: String.Encoding.utf8) {
                paramString = param
            }
        } catch {
            log.error("Google Url Shortener - Parameter cannot be set to the request: \(error.localizedDescription)")
        }
        
        let headers = ["Content-Type": "application/json"]
        let url = EndPoints().googleUrlShortenerUrl + "?key=" + EndPoints().googleUrlShortnerApiKey

        Alamofire.request(url, method: .post, parameters: [:], encoding: paramString, headers: headers)
            .responseJSON { response in
                var shortUrl: String?
                var error: NSError?
                
                //TODO: Should we restrict google url shortener key for iOS Bundle ID?
                if response.result.isSuccess {
                    let responseDict = response.result.value as! NSDictionary
                    if let id = responseDict.value(forKey: "id") as! String? {
                        shortUrl = id

                    } else {
                        var userInfo: [AnyHashable : Any] = [:]
                        var message: String = "Unknown Error"
                        
                        if let errorFromServer = responseDict.value(forKey: "error") as! NSDictionary? {
                            if let messageFromServer = errorFromServer.value(forKey: "message") as! String? {
                                message = messageFromServer
                            }
                        }
                        
                        userInfo = [
                            NSLocalizedDescriptionKey : message,
                            NSLocalizedFailureReasonErrorKey : message
                        ]
                        error = NSError(domain: EndPoints().googleUrlShortenerUrl, code: 500, userInfo: userInfo)
                    }
                } else {
                    error = response.error! as NSError
                }
                completionHandler(shortUrl, error)
        }
    }
}
