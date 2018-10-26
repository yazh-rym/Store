//
//  CustomerReportOperation.swift
//  Tryon
//
//  Created by Udayakumar N on 06/04/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Alamofire

class CustomerReportOperation: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    var operationQueue: OperationQueue = OperationQueue()

    // MARK: - Customer report functions
    func updateCustomerReport(customer: CustomerReport, startTime: Date, completionHandler : @escaping (_ error: NSError?) -> Void) {
                
        let blockOperation: BlockOperation = BlockOperation.init(
            block: {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                let timeString = dateFormatter.string(from: startTime)
                let elapsedSeconds = Int(Date().timeIntervalSince(startTime))
                
                var customerSelected2DProductsDict: [[String: Any]] = []
                for customerSelected2DProduct in customer.customerSelected2DProducts! {
                    if let endTime = customerSelected2DProduct.endTime {
                        let elapsedSeconds = Int(endTime.timeIntervalSince(customerSelected2DProduct.startTime!))
                        let dict: [String: Any] = ["1000lookz_id": customerSelected2DProduct.lookzId!, "time": elapsedSeconds]
                        customerSelected2DProductsDict.append(dict)
                    }
                }
                
                var customerSelected3DProductsDict: [[String: Any]] = []
                for customerSelected3DProduct in customer.customerSelected3DProducts! {
                    if let endTime = customerSelected3DProduct.endTime {
                        let elapsedSeconds = Int(endTime.timeIntervalSince(customerSelected3DProduct.startTime!))
                        let dict: [String: Any] = ["1000lookz_id": customerSelected3DProduct.lookzId!, "time": elapsedSeconds]
                        customerSelected3DProductsDict.append(dict)
                    }
                }
                
                var mobileNumberInt: Int64?
                if let customerMobileNumber = customer.customerMobileNumber {
                    if let mobileNumber = Int64(customerMobileNumber) {
                        mobileNumberInt = mobileNumber
                    }
                }
                
                let params: Parameters = ["device_id" : self.model.deviceId,
                                          "device_start_time" : timeString,
                                          "device_spent_time" : elapsedSeconds,
                                          "customer_type" : customer.customerType ?? NSNull(),
                                          "customer_mobile": mobileNumberInt ?? NSNull(),
                                          "customer_video_type": customer.customerVideoType ?? NSNull(),
                                          "customer_video_url": customer.customerVideoUrl ?? NSNull(),
                                          "customer_gender": customer.customerGender ?? NSNull(),
                                          "customer_age": customer.customerAge ?? NSNull(),
                                          "customer_frontal_face_image": customer.customerFrontalFaceImgUrl ?? NSNull(),
                                          "customer_2d_products": customerSelected2DProductsDict,
                                          "customer_3d_products": customerSelected3DProductsDict,
                                          "customer_favorite_products": []]
                
                var paramString: String = ""
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: params)
                    if let param = String(data: jsonData, encoding: String.Encoding.utf8) {
                        paramString = param
                    }
                } catch {
                    log.error("User Render - Parameter cannot be set to the request: \(error.localizedDescription)")
                }
                
                let headers = ["Content-Type": "application/json"]
                Alamofire.request(EndPoints().updateCustomerReport, method: .post, parameters: [:], encoding: paramString, headers: headers)
                    .responseJSON { response in
                        var error: NSError?
                        
                        if response.result.isSuccess {
                            let responseDict = response.result.value as! NSDictionary
                            
                            if responseDict.value(forKey: "status") as! String == "success" || responseDict.value(forKey: "status") as! String == "OK" {
                                completionHandler(nil)
                                return
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
                                error = NSError(domain: EndPoints().updateCustomerReport, code: 500, userInfo: userInfo)
                            }
                        } else {
                            error = response.error! as NSError
                        }
                        completionHandler(error)
                }
        })
        
        operationQueue.addOperation(blockOperation)
    }
}
