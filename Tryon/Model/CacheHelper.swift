//
//  CacheHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 02/02/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import Foundation
import UIKit


class CacheHelper: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    // MARK: - Image functions
    func addToCache(_ image: UIImage, withIdentifier identifier: String) {
        self.model.imageCache.add(image, withIdentifier: identifier)
    }
    
    func imageFromCache(withIdentifier identifier: String) -> UIImage? {
        return self.model.imageCache.image(withIdentifier: identifier)
    }
    
    func add(_ image: UIImage, withIdentifier identifier: String, in representation: String) {
        let fileManager = FileManager.default
        let path = (FileHelper().getCacheDirectoryPath() as NSString).appendingPathComponent("\(identifier).\(representation.lowercased())")
        var imageData: Data?
        
        if representation.lowercased() == "jpg" {
            imageData = UIImageJPEGRepresentation(image, 0.9)
        } else if representation.lowercased() == "png" {
            imageData = UIImagePNGRepresentation(image)
        } else {
            imageData = UIImageJPEGRepresentation(image, 0.9)
        }
        
        fileManager.createFile(atPath: path, contents: imageData, attributes: nil)
    }
    
    func image(withIdentifier identifier: String, in representation: String) -> UIImage? {
        let fileManager = FileManager.default
        let imagePath = (FileHelper().getCacheDirectoryPath() as NSString).appendingPathComponent("\(identifier).\(representation.lowercased())")
        
        if fileManager.fileExists(atPath: imagePath) {
            //let data = NSData(contentsOf: NSURL(fileURLWithPath: imagePath) as URL)!
            //log.info("File size for ID: \(identifier): \(Double(Double(data.length) / 1048576.0)) MB")
            
            let img = UIImage(contentsOfFile: imagePath)!
            return img
        } else {
            return nil
        }
    }
    
    func imageFilePath(forIdentifier identifier: String, in representation: String) -> String? {
        let fileManager = FileManager.default
        let imagePath = (FileHelper().getCacheDirectoryPath() as NSString).appendingPathComponent("\(identifier).\(representation.lowercased())")
        
        if fileManager.fileExists(atPath: imagePath) {
            return imagePath
        } else {
            return nil
        }
    }
}
