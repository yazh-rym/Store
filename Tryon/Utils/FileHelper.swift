//
//  FileHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 23/06/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import SwiftyJSON

var fileStrName = [String]()
class FileHelper: NSObject {
    
    //MARK: - File Helper functions
    func getDocumentDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    func fileExists(atPath path: String) -> Bool {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: path) {
            return true
        } else {
            return false
        }
    }
    
    func write(dictionary: NSDictionary?, toFile fileName: String) -> String? {
        guard let dictionary = dictionary else {
            return nil
        }
        
        let path = (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fileName)
        let json = JSON(dictionary)
        let jsonString = json.rawString()

        do {
            try jsonString?.write(to: NSURL(fileURLWithPath: path) as URL, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            return nil
        }
        
        return path
    }
    
    func getCacheDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    func removeAllJpgFilesFromCache() {
        removeFiles(fromDirectory: .cachesDirectory, withSuffix: ".jpg")
    }
    
    func removeAllPngFilesFromCache() {
        removeFiles(fromDirectory: .cachesDirectory, withSuffix: ".png")
    }
    
    func removeAllFilesFromCache() {
        removeAllJpgFilesFromCache()
        removeAllPngFilesFromCache()
    }
    
    func removeAllSnapJpgFilesCaches() {
        filename(fromDirectory: .cachesDirectory)
        for i in 0...(fileStrName.count)-1 {
            let arr = fileStrName[i].components(separatedBy: ".jpg")
            let string = arr[0]
            if string.range(of: "Model") != nil {
//                print("namessssssss")
//                print(fileStrName[i])
            } else {
                removeFiles(fromDirectory: .cachesDirectory, withSuffix: fileStrName[i])
//                print(fileStrName[i])
            }
        }
    }
    
    func filename(fromDirectory directory: FileManager.SearchPathDirectory) {
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: directory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                for fileName in fileNames {
                    fileStrName.append(fileName)
                }
            }
        } catch {
            log.warning("Could not clear folder - \(directory) - \(error)")
        }
    }
    
    func removeFiles(fromDirectory directory: FileManager.SearchPathDirectory, withSuffix suffix: String) {
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: directory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                for fileName in fileNames {
                    if (fileName.hasSuffix(suffix)) {
                        let filePathName = "\(documentPath)/\(fileName)"
                        try fileManager.removeItem(atPath: filePathName)
                    }
                }
                //let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                //log.warning("All files in cache after deleting images: \(files)")
            }
        } catch {
            log.warning("Could not clear folder - \(directory) - \(error)")
        }
    }
}
