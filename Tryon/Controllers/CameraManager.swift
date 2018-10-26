//
//  CameraManager.swift
//  Tryon
//
//  Created by Udayakumar N on 20/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol CameraManagerDelegate: NSObjectProtocol {
    func cameraAccessDenied()
    func cameraInitializeFailed()
    func cameraAccessGranted()
}

class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var session = AVCaptureSession()
    var videoDataOutput = AVCaptureVideoDataOutput()
    var stillImageOutput = AVCaptureStillImageOutput()
    var movieOutput = AVCaptureMovieFileOutput()
    var currentCameraDevice:AVCaptureDevice?
    var metadataOutput = AVCaptureMetadataOutput()
    weak var cameraManagerDelegate: CameraManagerDelegate?

    private var dataOutputQueue = DispatchQueue(label: Bundle.main.bundleIdentifier ?? "" + "-dataOutputQueue")
    private var sessionQueue = DispatchQueue(label: Bundle.main.bundleIdentifier ?? ""  + "-videoQueue")
    
    // MARK: - Init functions
    override init() {
        super.init()

        previewLayer = AVCaptureVideoPreviewLayer(session: self.session) as AVCaptureVideoPreviewLayer
        session.sessionPreset = AVCaptureSessionPresetPhoto
    }
    
    func checkCameraAccess() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                          completionHandler: { (granted:Bool) -> Void in
                                            if granted {
                                                self.configureSession()
                                            }
                                            else {
                                                self.cameraManagerDelegate?.cameraAccessDenied()
                                            }
            })
            
        case .authorized:
            configureSession()
            
        case .denied:
            self.cameraManagerDelegate?.cameraAccessDenied()
            
        case .restricted:
            self.cameraManagerDelegate?.cameraAccessDenied()
            
        }
    }
    
    func configureSession() {
        self.configureDeviceInput()
        self.configureVideoOutput()
        self.configureImageOutput()
        self.configureMetaDataOutput()
        self.cameraManagerDelegate?.cameraAccessGranted()
    }

    func configureDeviceInput() {
        if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
            if device.position == .front {
                self.currentCameraDevice = device
                
                //Configure Frame Rate
                do {
                    try self.currentCameraDevice?.lockForConfiguration()
                    self.currentCameraDevice?.activeVideoMinFrameDuration = CMTimeMake(1, Int32(model.appVideoFrameRate))
                    self.currentCameraDevice?.activeVideoMaxFrameDuration = CMTimeMake(1, Int32(model.appVideoFrameRate))
                    self.currentCameraDevice?.setExposureTargetBias(0.33, completionHandler: nil)
                    
                    if (self.currentCameraDevice?.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance))! {
                        self.currentCameraDevice?.whiteBalanceMode = .continuousAutoWhiteBalance
                    } else if (self.currentCameraDevice?.isWhiteBalanceModeSupported(.autoWhiteBalance))! {
                        self.currentCameraDevice?.whiteBalanceMode = .autoWhiteBalance
                    }
                    
                    if (self.currentCameraDevice?.isFocusModeSupported(.continuousAutoFocus))! {
                        self.currentCameraDevice?.focusMode = .continuousAutoFocus
                    } else if (self.currentCameraDevice?.isFocusModeSupported(.autoFocus))! {
                        self.currentCameraDevice?.focusMode = .autoFocus
                    }
                    
                    if (self.currentCameraDevice?.isExposureModeSupported(.continuousAutoExposure))! {
                        self.currentCameraDevice?.exposureMode = .continuousAutoExposure
                    } else if (self.currentCameraDevice?.isExposureModeSupported(.autoExpose))! {
                        self.currentCameraDevice?.exposureMode = .autoExpose
                    }
                    
                    self.currentCameraDevice?.unlockForConfiguration()
                    
                } catch let error {
                    log.error("Lock camera error while configuring Frame rate - \(error)")
                }
                
                //FOV of front camera
                log.info("Front camera FOV: \(String(describing: self.currentCameraDevice?.activeFormat.videoFieldOfView))")
            }
        }
    
        do {
            let possibleCameraInput = try AVCaptureDeviceInput(device: self.currentCameraDevice)
            if self.session.canAddInput(possibleCameraInput) {
                self.session.addInput(possibleCameraInput);
            }
        }
        catch{
            log.error("Cannot initialize Camera's Input");
            self.cameraManagerDelegate?.cameraInitializeFailed()
        }
    }
    
    func configureVideoOutput() {
        self.videoDataOutput.videoSettings = nil
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        if self.session.canAddOutput(self.videoDataOutput) {
            self.session.addOutput(self.movieOutput)
            let connection = self.movieOutput.connection(withMediaType: AVFoundation.AVMediaTypeVideo)
            connection?.videoOrientation = .portrait
        }

        self.videoDataOutput.setSampleBufferDelegate(self, queue: self.dataOutputQueue)
    }
    
    func configureImageOutput() {
        self.stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if self.session.canAddOutput(stillImageOutput) {
            self.session.addOutput(stillImageOutput)
        }
    }
    
    func configureMetaDataOutput() {
        //Configure Metadata for Face detection
        if self.session.canAddOutput(self.metadataOutput) {
            self.session.addOutput(self.metadataOutput)
            
            self.metadataOutput.setMetadataObjectsDelegate(self.cameraManagerDelegate as! AVCaptureMetadataOutputObjectsDelegate!, queue: sessionQueue)
            
            if self.metadataOutput.availableMetadataObjectTypes.contains(where: { object_type in
                return object_type as! String == AVMetadataObjectTypeFace
            }) {
                self.metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
            } else {
                log.error("No Face support")
            }
        }
    }
    
    func startRunning() {
        self.session.startRunning()
    }
    
    func stopRunning() {
        self.session.stopRunning()
    }
}
