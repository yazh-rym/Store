//
//  AWSDownloadHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 23/06/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import AWSS3


class AWSDownloadHelper: NSObject {

    //Function to download file from S3
    func downloadFile(fileURL: NSURL, bucketName: String, s3DownloadKeyName: String, completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?, progressBlock: AWSS3TransferUtilityProgressBlock?) {
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = progressBlock
        
        log.info("File Download Time: Start - \(Date())")
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.downloadData(fromBucket: bucketName, key: s3DownloadKeyName, expression: expression, completionHandler: completionHandler).continueWith(block: { (task) -> Any? in
            
            if let error = task.error {
                log.error("Error in Downloading Video: \(error)")
            } else {
                log.info("File Download Time: End - \(Date())")
            }
            
            return nil
        })
    }
}
