//
//  AWSUploadHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 25/05/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Alamofire
import AWSS3


class AWSUploadHelper: NSObject {
    
    //Function to upload Video to S3
    func uploadVideo(fileURL: NSURL, bucketName: String, fileS3UploadKeyName: String, completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?, progressBlock: AWSS3TransferUtilityProgressBlock?) {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = progressBlock
        
        log.info("Video Upload Time: Start - \(Date())")
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadFile(fileURL as URL, bucket: bucketName, key: fileS3UploadKeyName, contentType: "video/jpeg", expression: expression, completionHandler: completionHandler).continueWith(block: { (task) -> Any? in
            if let error = task.error {
                log.error("Error in Uploading Video: \(error)")
            } else {
                log.info("Video Upload Time: End - \(Date())")
            }
            
            return nil
        })
    }
    
    //Function to upload image to S3
    func uploadImage(fileURL: NSURL, bucketName: String, fileS3UploadKeyName: String, completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?, progressBlock: AWSS3TransferUtilityProgressBlock?) {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = progressBlock
        
        log.info("Image Upload Time: Start - \(Date())")
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadFile(fileURL as URL, bucket: bucketName, key: fileS3UploadKeyName, contentType: "image/jpeg", expression: expression, completionHandler: completionHandler).continueWith(block: { (task) -> Any? in
            if let error = task.error {
                log.error("Error in Uploading Image: \(error)")
            } else {
                log.info("Image Upload Time: End - \(Date())")
            }
            
            return nil
        })
    }
    
    //Function to upload file to S3
    func uploadFile(fileURL: NSURL, contentType: String, bucketName: String, fileS3UploadKeyName: String, completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?, progressBlock: AWSS3TransferUtilityProgressBlock?) {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = progressBlock
        
        log.info("File Upload Time: Start - \(Date())")
        
        let transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadFile(fileURL as URL, bucket: bucketName, key: fileS3UploadKeyName, contentType: contentType, expression: expression, completionHandler: completionHandler).continueWith(block: { (task) -> Any? in
            if let error = task.error {
                log.error("Error in Uploading File: \(error)")
            } else {
                log.info("File Upload Time: End - \(Date())")
            }
            
            return nil
        })
    }
}
