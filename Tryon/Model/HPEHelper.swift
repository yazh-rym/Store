//
//  HPEHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 07/12/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class HPEHelper: NSObject {

    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    let googleCloudVisionUrl = URL(string: "\(EndPoints().googleCloudVisionUrl)?key=\(EndPoints().googleCloudVisionApiKey)")!
    
    var selectedFrameNumbers: [Int] = []
    var y: [Int: Double] = [:]
    var p: [Int: Double] = [:]
    var r: [Int: Double] = [:]
    var ypr: [Int: String] = [:]
    var sellionPoints: [Int: CGPoint] = [:]
    var eyeToEyeDistance: [Int: Double] = [:]
    var eyeToEyeDistanceOfFrontFrame: Double = 0.0
    var frontFrameIndex: Int = 0
    let eyeFrameScaleFactor: Double = 1.6
    
    func extractFrameFromImage(internalUserName: String, image: UIImage, lowResImage: UIImage, completionHandler: @escaping (_ newUser: User?, _ error: NSError?) -> Void) {
        self.selectedFrameNumbers.append(1)
        
        self.getFaceDetection(forFrameNumbers: [1], images: [lowResImage], completionHandler: { (faceDetectionError) in
            if faceDetectionError == nil {
                let serverFaceSize = self.model.serverImageSize
                let glassUrl = EndPoints().s3PreRenderedUrl
                let jsonUrl = EndPoints().s3PreRenderedUrl
                
                //Find front frame index
                let smallestY = self.y.values.enumerated().min( by: { abs($0.1) < abs($1.1) } )!
                for frame in self.selectedFrameNumbers {
                    if self.y[frame] == smallestY.element {
                        self.frontFrameIndex = self.selectedFrameNumbers.index(of: frame)!
                        self.eyeToEyeDistanceOfFrontFrame = self.eyeToEyeDistance[frame]!
                    }
                }
                
                let newUser = User(yprValues: [self.ypr[1]!], sellionPoints: [self.sellionPoints[1]!], frameNumbers: self.selectedFrameNumbers, frontFrameIndex: self.frontFrameIndex, eyeToEyeDistance: self.eyeToEyeDistanceOfFrontFrame, eyeFrameScaleFactor: self.eyeFrameScaleFactor, serverFaceSize: serverFaceSize, glassUrl: glassUrl, jsonUrl: jsonUrl, userType: UserType.user, serverVideoUrl: nil, frontFaceImgUrl: nil, internalUserName: internalUserName, shouldRenderImages: true, appVideoUrl: "", appVideoFPS: nil, userInputType: .image, image: image)
                self.tryon3D.user = newUser
                self.tryon3D.isUserSelectedByAppUser = true
                
                completionHandler(newUser, faceDetectionError)
            } else {
                completionHandler(nil, faceDetectionError)
            }
        })
    }
    
    func extractFramesFromVideo(internalUserName: String, videoUrl: NSURL, videoFPS: Int, completionHandler: @escaping (_ newUser: User?, _ error: NSError?) -> Void) {
        let numberOfFrames: Int = ImageHelper().numberOfFrames(inVideoUrl: videoUrl as URL)
        let frameFrequency: Double = Double(numberOfFrames) / Double(model.maxNumberOf3DFrames)
        let frameFrequencyRounded: Double = (frameFrequency * 10).rounded() / 10

        var i: Double = 1.0
        while Int(i) <= numberOfFrames {
            selectedFrameNumbers.append(Int(i))
            
            i = i + frameFrequencyRounded
        }
        
        getAllFrames(forFrameNumbers: selectedFrameNumbers, fromVideoUrl: videoUrl, appVideoFPS: videoFPS, completionHandler: { (error) in
            
            if error == nil {
                var yprValues: [String] = []
                var sellionPoints: [CGPoint] = []
                let serverFaceSize = self.model.serverVideoSize
                let glassUrl = EndPoints().s3PreRenderedUrl
                let jsonUrl = EndPoints().s3PreRenderedUrl
                
                var extremeAngledFrames: [Int] = []
                
                var i = -1
                for frame in self.selectedFrameNumbers {
                    i = i + 1
                    let ypr = self.ypr[frame]!
                    let yprArray = ypr.components(separatedBy: "_")
                    let y = yprArray.first
                    if let yDouble = Double(y!) {
                        if (yDouble > 36.0) || (yDouble < -36.0) {
                            if i != self.frontFrameIndex {
                                extremeAngledFrames.append(i)
                                continue
                            }
                        }
                    }
                    
                    yprValues.append(self.ypr[frame]!)
                    sellionPoints.append(self.sellionPoints[frame]!)
                }
                
                //Reversed to make sure that higher indexes are removed first
                for extremeIndex in extremeAngledFrames.reversed() {
                    self.selectedFrameNumbers.remove(at: extremeIndex)
                }
                
                //Find front frame index
                let smallestY = self.y.values.enumerated().min( by: { abs($0.1) < abs($1.1) } )!
                for frame in self.selectedFrameNumbers {
                    if self.y[frame] == smallestY.element {
                        self.frontFrameIndex = self.selectedFrameNumbers.index(of: frame)!
                        self.eyeToEyeDistanceOfFrontFrame = self.eyeToEyeDistance[frame]!
                    }
                }
                
                let appLocalVideoUrl = (FileHelper().getDocumentDirectoryPath() as NSString).appendingPathComponent(internalUserName + "-local.mov")
                
                let newUser = User(yprValues: yprValues, sellionPoints: sellionPoints, frameNumbers: self.selectedFrameNumbers, frontFrameIndex: self.frontFrameIndex, eyeToEyeDistance: self.eyeToEyeDistanceOfFrontFrame, eyeFrameScaleFactor: self.eyeFrameScaleFactor, serverFaceSize: serverFaceSize, glassUrl: glassUrl, jsonUrl: jsonUrl, userType: UserType.user, serverVideoUrl: nil, frontFaceImgUrl: nil, internalUserName: internalUserName, shouldRenderImages: true, appVideoUrl: appLocalVideoUrl, appVideoFPS: videoFPS, userInputType: .video, image: nil)
                self.tryon3D.user = newUser
                self.tryon3D.isUserSelectedByAppUser = true
                
                completionHandler(newUser, error)
            } else {
                completionHandler(nil, error)
            }
        })
    }
    
    func getAllFrames(forFrameNumbers frameNumbers: [Int], fromVideoUrl videoUrl: NSURL, appVideoFPS: Int, completionHandler: @escaping (_ error: NSError?) -> Void) {
        //Get all the frames
        var images: [UIImage] = []
        for frameNumber in frameNumbers {
            let time = CMTimeMake(Int64(frameNumber), Int32(appVideoFPS))
            
            if let img = ImageHelper().image(fromVideoUrl: videoUrl as URL, atTime: time) {
                log.info("Getting user frame for user-\(frameNumber) to find YPR")
                images.append(img)
            } else {
                log.warning("UserImage couldn't be extracted for identifier: user\(frameNumber)")
            }
        }
        self.getFaceDetection(forFrameNumbers: frameNumbers, images: images, completionHandler: { (faceDetectionError) in
            completionHandler(faceDetectionError)
        })
    }
    
    func getFaceDetection(forFrameNumbers frames: [Int], images imgs: [UIImage], completionHandler: @escaping (_ error: NSError?) -> Void) {
        
        var params: Parameters = [
            "requests": []
        ]
        
        var allRequests: [NSDictionary] = []
        
        var i = 0
        for img in imgs {
            let imagedata = UIImageJPEGRepresentation(img, self.model.serverImageJPGCompression)
            let binaryImageData = imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
            
            let requestParam: NSDictionary = [
                "image": [
                    "content": binaryImageData
                ],
                "features": [
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 5
                    ]
                ]
            ]
            allRequests.append(requestParam)
            
            i = i + 1
        }
        params["requests"] = allRequests
        let parameterJson = JSON(params)
        let parameter = parameterJson.rawString()
        
        let headers = ["Content-Type": "application/json", "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""]
        
        Alamofire.request(self.googleCloudVisionUrl, method: .post, parameters: [:], encoding: parameter!, headers: headers)
            .responseJSON { response in
                var error: NSError?
                
                if response.result.isSuccess {
                    
                    let responseJson = try! JSON(data: response.data!)
                    let errorObject: JSON = responseJson["error"]
                    
                    if (errorObject.dictionaryValue != [:]) {
                        var userInfo: [AnyHashable : Any] = [:]
                        var message: String = "Unknown Error"
                        var code: Int = 500
                        
                        if let messageFromServer = errorObject["message"].string as String? {
                            message = messageFromServer
                        }
                        
                        if let codeFromServer = errorObject["code"].int as Int? {
                            code = codeFromServer
                        }
                        
                        userInfo = [
                            NSLocalizedDescriptionKey : message,
                            NSLocalizedFailureReasonErrorKey : message
                        ]
                        error = NSError(domain: EndPoints().googleCloudVisionUrl, code: code, userInfo: userInfo)
                        
                        log.error("Detecting face from Google Cloud failed with code / message as \(String(describing: code)) and \(message)")
                    } else {
                        // Parse the response
                        if let responses: [JSON] = responseJson["responses"].array {
                            
                            var i = 0
                            for response in responses {
                                let faceAnnotations: JSON = response["faceAnnotations"]
                                let frame = frames[i]
                                
                                if faceAnnotations != JSON.null {
                                    let numPeopleDetected: Int = faceAnnotations.count
                                    log.info("Number of People detected: \(numPeopleDetected)")
                                    
                                    //Take the first face
                                    let personData:JSON = faceAnnotations[0]
                                    
                                    let y = 0.0 - (personData["panAngle"].rawValue as! Double)
                                    let p = 0.0 - (personData["tiltAngle"].rawValue as! Double)
                                    let r = 0.0 - (personData["rollAngle"].rawValue as! Double)
                                    var leftCorner: CGPoint?
                                    var rightCorner: CGPoint?
                                    var sellionPoint: CGPoint?
                                    let landmarks = personData["landmarks"]
                                    
                                    for landmark in landmarks.array! {
                                        if landmark["type"] == "LEFT_EYE_LEFT_CORNER" {
                                            leftCorner = CGPoint(x: landmark["position"]["x"].rawValue as! Double, y: landmark["position"]["y"].rawValue as! Double)
                                            
                                        } else if landmark["type"] == "RIGHT_EYE_RIGHT_CORNER" {
                                            rightCorner = CGPoint(x: landmark["position"]["x"].rawValue as! Double, y: landmark["position"]["y"].rawValue as! Double)
                                            
                                        } else if landmark["type"] == "MIDPOINT_BETWEEN_EYES" {
                                            sellionPoint = CGPoint(x: landmark["position"]["x"].rawValue as! Double, y: landmark["position"]["y"].rawValue as! Double)
                                            
                                        }
                                    }
                                    
                                    //Update the values
                                    let eyeToEyeDistance = Double((rightCorner?.x)!) - Double((leftCorner?.x)!)
                                    self.y.updateValue(y, forKey: frame)
                                    self.p.updateValue(p, forKey: frame)
                                    self.r.updateValue(r, forKey: frame)
                                    self.ypr.updateValue("\(y)_\(p)_\(r)", forKey: frame)
                                    self.sellionPoints.updateValue(sellionPoint!, forKey: frame)
                                    self.eyeToEyeDistance.updateValue(eyeToEyeDistance, forKey: frame)
                                    
                                    //Find front frame index
                                    let smallestY = self.y.values.enumerated().min( by: { abs($0.1) < abs($1.1) } )!
                                    for frame in self.selectedFrameNumbers {
                                        if self.y[frame] == smallestY.element {
                                            self.frontFrameIndex = self.selectedFrameNumbers.index(of: frame)!
                                            self.eyeToEyeDistanceOfFrontFrame = self.eyeToEyeDistance[frame]!
                                        }
                                    }
                                } else {
                                    var userInfo: [AnyHashable : Any] = [:]
                                    let message: String = "No faces found"
                                    
                                    userInfo = [
                                        NSLocalizedDescriptionKey : message,
                                        NSLocalizedFailureReasonErrorKey : message
                                    ]
                                    
                                    error = NSError(domain: self.googleCloudVisionUrl.absoluteString, code: 500, userInfo: userInfo)
                                }
                                
                                i = i + 1
                            }
                        }
                    }
                } else {
                    error = response.error! as NSError
                }
                
                completionHandler(error)
        }
    }
}
