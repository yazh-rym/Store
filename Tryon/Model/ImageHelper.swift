//
//  ImageHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 22/06/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit


class ImageHelper: NSObject {
    
    // MARK: - Image functions
    func image(fromVideoUrl url: URL, atTime time: CMTime) -> UIImage? {
        var img: UIImage?
        let asset: AVURLAsset = AVURLAsset(url: url)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        
        imgGenerator.requestedTimeToleranceAfter = kCMTimeZero
        imgGenerator.requestedTimeToleranceBefore = kCMTimeZero
        do {
            let cgImage = try imgGenerator.copyCGImage(at: time, actualTime: nil)
            img = UIImage(cgImage: cgImage)
        } catch {
            log.error("Getting Image from Video failed - \(error) for url: \(url) at time: \(time)")
        }
        
        return img
    }
    
    func numberOfFrames(inVideoUrl url: URL) -> Int {
        let asset: AVURLAsset = AVURLAsset(url: url)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo ).first! as AVAssetTrack
        
        let durationInSeconds = CMTimeGetSeconds(asset.duration)
        let framesPerSecond = assetTrack.nominalFrameRate
        
        //Number of Frames
        return Int(round(Float(durationInSeconds) * framesPerSecond))
    }
}
