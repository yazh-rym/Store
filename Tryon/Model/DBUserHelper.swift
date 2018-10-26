//
//  DBUserHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 31/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift


class DBUserHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    
    // MARK: - Filter User data
    func getUserDetails(completionHandler : @escaping (_ dbUsers: [DBUser], _ error: NSError?) -> Void) {
        
        let headers = ["Authorization": self.model.accessToken, "Content-Type": "application/json"]
        
        Alamofire.request(EndPoints().getUserUrl, method: .get, parameters: [:], headers: headers)
            .responseJSON { response in
                var dbUsers: [DBUser] = []
                var error: NSError?
                
                var userInfo: [AnyHashable : Any] = [:]
                let message: String = "Unknown Error"
                userInfo = [
                    NSLocalizedDescriptionKey : message,
                    NSLocalizedFailureReasonErrorKey : message
                ]
                let unknownError = NSError(domain: EndPoints().getUserUrl, code: 500, userInfo: userInfo)
                
                switch response.result {
                case .failure(let error):
                    log.error(error)
                    
                    completionHandler(dbUsers, error as NSError)
                    
                case .success(let responseObject):
                    if let usersDict = responseObject as? NSDictionary {
                        if let users = usersDict.value(forKey: "users") as? [NSDictionary] {
                            for user in users {
                                let name = user.value(forKey: "name") as? String
                                let id = user.value(forKey: "id") as? Int
                                let parentUserId = user.value(forKey: "parent_userid") as? Int
                                
                                let address1 = user.value(forKey: "address1") as? String
                                let address2 = user.value(forKey: "address2") as? String
                                let district = user.value(forKey: "district") as? String
                                let state = user.value(forKey: "state") as? String
                                let pincode = user.value(forKey: "pincode") as? String
//                                let logoUrl = user.value(forKey: "logo_url") as? String
//                                let username = user.value(forKey: "username") as? String
//                                let email = user.value(forKey: "email") as? String
//                                let userTypeId = user.value(forKey: "user_type_id") as? Int
                                
                                //Get only the accounts and not distributor sales
                                if parentUserId == nil {
                                    let dbUser = DBUser(value: ["id": id as Any, "name": name as Any, "address1": address1 as Any, "address2": address2 as Any, "district": district as Any, "state": state as Any, "pincode": pincode as Any])//, "logo_url": logoUrl as Any, "username": username as Any, "user_type_id": userTypeId as Any, "email": email as Any])
                                    dbUsers.append(dbUser)
                                } else {
                                    //Ignore this user
                                }
                            }
                        }
                    } else if let errorResponse = (responseObject as AnyObject).value(forKey: "error") as? NSDictionary {
                        //Error
                        let statusCode = errorResponse.value(forKey: "statusCode") as? Int
                        let message = errorResponse.value(forKey: "message") as? String
                        let userInfo = [
                            NSLocalizedDescriptionKey : message!,
                            NSLocalizedFailureReasonErrorKey : message!
                        ]
                        
                        error = NSError(domain: EndPoints().getUserUrl, code: statusCode!, userInfo: userInfo)
                    } else {
                        //Unknown error
                        error = unknownError
                    }
                    
                    completionHandler(dbUsers, error)
                }
        }
    }
}
