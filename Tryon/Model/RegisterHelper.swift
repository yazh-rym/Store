//
//  RegisterHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 27/12/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class RegisterHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    
    // MARK: - Register functions
    func registerUser(username: String, password: String, completionHandler : @escaping (_ accessToken: String?, _ userId: Int?, _ error: NSError?) -> Void) {
        let parameterDict = ["username" : username, "password" : password] as [String : String]
        let parameterJson = JSON(parameterDict)
        let parameter = parameterJson.rawString()
        
        let headers = ["Content-Type": "application/json"]

        Alamofire.request(EndPoints().registerUserUrl, method: .post, parameters: [:], encoding: parameter!, headers: headers)
            .responseJSON { response in
                var accessToken: String?
                var userId: Int?
                var error: NSError?
                
                var userInfo: [AnyHashable : Any] = [:]
                let message: String = "Unknown Error"
                userInfo = [
                    NSLocalizedDescriptionKey : message,
                    NSLocalizedFailureReasonErrorKey : message
                ]
                let unknownError = NSError(domain: EndPoints().registerUserUrl, code: 500, userInfo: userInfo)
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                
                    completionHandler(accessToken, userId, error as NSError)
                    
                case .success(let responseObject):
                    if let response = responseObject as? NSDictionary {
                        if let errorResponse = response.value(forKey: "error") as? NSDictionary {
                            //Error
                            let statusCode = errorResponse.value(forKey: "statusCode") as? Int
                            let message = errorResponse.value(forKey: "message") as? String
                            let userInfo = [
                                NSLocalizedDescriptionKey : message!,
                                NSLocalizedFailureReasonErrorKey : message!
                            ]
                            
                            error = NSError(domain: EndPoints().registerUserUrl, code: statusCode!, userInfo: userInfo)
                            
                        } else if let id = response.value(forKey: "id") as? String {
                            //Success
                            accessToken = id
                            userId = response.value(forKey: "userId") as? Int
                            
                        } else {
                            //Unknown error
                            error = unknownError
                            
                        }
                    } else {
                        //Unknown Error
                        error = unknownError
                    }
                    completionHandler(accessToken, userId, error)
                }
        }
    }
    
    func registerUserLogo(accessToken: String, userIdentity: Int, completionHandler : @escaping (_ username: String?, _ logoUrl: String?, _ error: NSError?) -> Void) {
        let headers = ["Authorization": accessToken, "Content-Type": "application/json"]
        let url = EndPoints().getlogoUrl+String(userIdentity)
        
        Alamofire.request(url, method: .get, parameters: nil, headers: headers)
            .responseJSON { response in
                print(response.result)
                var username: String?
                var logoUrl: String?
                var name: String?
                var address: String?
                var address1: String?
                var district: String?
                var pincode: String?
                var error: NSError?
                
                var userInfo: [AnyHashable : Any] = [:]
                let message: String = "Unknown Error"
                userInfo = [
                    NSLocalizedDescriptionKey : message,
                    NSLocalizedFailureReasonErrorKey : message
                ]
                let unknownError = NSError(domain: EndPoints().getlogoUrl, code: 500, userInfo: userInfo)
                switch response.result {
                case .failure(let error):
                    log.error(error)

                    completionHandler(username, logoUrl, error as NSError)

                case .success(let responseObject):
                    if let response = responseObject as? NSDictionary {
                    if let errorResponse = response.value(forKey: "error") as? NSDictionary {
                        //Error
                        let statusCode = errorResponse.value(forKey: "statusCode") as? Int
                        let message = errorResponse.value(forKey: "message") as? String
                        let userInfo = [
                            NSLocalizedDescriptionKey : message!,
                            NSLocalizedFailureReasonErrorKey : message!
                        ]
                        
                        error = NSError(domain: EndPoints().getlogoUrl, code: statusCode!, userInfo: userInfo)
                        
                    } else if let id = response.value(forKey: "id") {
                        //Success
                        logoUrl = response.value(forKey: "logo_url") as? String
                        username = response.value(forKey: "username") as? String
//                        id = response.value(forKey: "id") as? String
                        name = response.value(forKey: "name") as? String
                        address1 = response.value(forKey: "address1") as? String
                        district = response.value(forKey: "district") as? String
//                        let state = response.value(forKey: "state") as? String
                        pincode = response.value(forKey: "pincode") as? String
                        address = String(name!) + ", <br>" + String(address1!) + "<br>" + String(district!) + "-" + String(pincode!)
                        UserDefaults.standard.set(address, forKey: "address")

//                        let email = response.value(forKey: "email") as? String
//                        let userTypeId = response.value(forKey: "user_type_id") as? Int

                    } else {
                        //Unknown error
                        error = unknownError
                    }
                } else {
                    //Unknown Error
                    error = unknownError
                }
                    completionHandler(username, logoUrl, error)
            }
        }
    }
}

