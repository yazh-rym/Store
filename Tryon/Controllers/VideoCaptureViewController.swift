//
//  VideoCaptureViewController.swift
//  Tryon
//
//  Created by Udayakumar N on 16/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import AVFoundation
import Material
import SwiftyGif
import AWSS3
import NVActivityIndicatorView
import UICircularProgressRing
import ImageSlideshow
import Alamofire
import RealmSwift
import Kingfisher


enum ErrorType: Int {
    case cameraAccessDenied = 0
    case cameraInitializeDenied
    case videoRecordingFailed
    case videoProcessFailed
}

enum FaceAppearance: Int {
    case big = 0
    case small
    case left
    case right
    case top
    case bottom
    case perfect
    case noFace
}


class VideoCaptureViewController: BaseViewController, SomethingWentWrongDelegate, NVActivityIndicatorViewable, CameraManagerDelegate ,VideoDelegates{
    
    
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    var isReadyForRecording = false
    var canStartRecording = false
    var isRecordingStarted = false
    let realm = try! Realm()
    
    let imagesCount : Int = 12
    
    var inventoryArray : [InventoryFrame] = []
    
    var frame: InventoryFrame?
    
    var userModelClaArray : [UserModel] = []
    
    var tempImage: [UIImage] = []
    
    
    let cameraAccessDeniedText = "Please enable Camera Access from Settings -> Tryon"
    let cameraInitializeErrorText = "Cannot initialize Camera's Input"
    
    var faceAppearance: FaceAppearance?
    var currentErrorType: ErrorType?
    var videoOutputFilePath: NSURL = {
        let filePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie.mp4")?.absoluteString
        if FileManager.default.fileExists(atPath: filePath!) {
            do {
                try FileManager.default.removeItem(atPath: filePath!)
            } catch { }
        }
        return NSURL(string: filePath!)!
    }()
    var cameraManager = CameraManager()
    
    //Trim using FaceX
    var minFaceX: CGFloat?
    var maxFaceX: CGFloat?
    var frameNumberOfMinFaceX: Int = 0
    var frameNumberOfMaxFaceX: Int = 0
    var frameNumberOfCurrentFrame: Int = 0
    
    @IBOutlet weak var maskAnimationView: UIView!
    @IBOutlet weak var faceFrameView: UIView!
    @IBOutlet weak var faceSizeView: ImageSlideshow!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var flashView: UIView!
    
    @IBOutlet weak var backButtonView: OiCBackButtonView!
    @IBOutlet weak var snapButtonLabel: UILabel!
    @IBOutlet weak var shootButtonLabel: UILabel!
    @IBOutlet weak var snapShootButtonsHolderView: UIView!
    @IBOutlet weak var snapButtonHolderView: UIView!
    @IBOutlet weak var shootButtonHolderView: UIView!
    @IBOutlet weak var takeSnapButton: UIButton!
    @IBOutlet weak var takeSnapAnimationView: UIView!
    @IBOutlet weak var takeSnapAnimationLabel: UILabel!
    @IBOutlet weak var takeSnapAnimationImageView: UIImageView!
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var startRecordingAnimationView: UIView!
    @IBOutlet weak var startRecordingAnimationLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var premodelView: UIView!
    @IBOutlet weak var premodelImageView: UIImageView!
    
    
    
    
    
    var urlImage: [String] = []
    
    var userImages: [UIImage] = []
    
    
    var idValues: [String] = []
    
    var yprValues: [String] = []
    
    var valuesDict : [NSDictionary] = []
    var classDict : [NSDictionary] = []
    
    var imagesDict : [NSDictionary] = []
    
    
    
    var imageArray: [UIImage] = []
    
    var finalImageArray: [UIImage] = []
    
    
    @IBAction func snapButtonDidTap(_ sender: UIButton) {
        self.cameraManager.session.sessionPreset = AVCaptureSessionPresetPhoto
        
        self.snapButtonHolderView.isHidden = true
        self.shootButtonHolderView.isHidden = true
        self.startRecordingButton.isHidden = true
        self.takeSnapButton.isHidden = false
        self.backButtonView.isHidden = false
        self.faceSizeView.isHidden = true
    }
    
    @IBAction func shootButtonDidTap(_ sender: UIButton) {
        self.cameraManager.session.sessionPreset = AVCaptureSessionPresetHigh
        self.cameraManager.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.snapButtonHolderView.isHidden = true
        self.shootButtonHolderView.isHidden = true
        self.takeSnapButton.isHidden = true
        self.startRecordingButton.isHidden = false
        self.faceSizeView.isHidden = false
        self.backButtonView.isHidden = false
    }
    
    @IBAction func takeSnapDidTap(_ sender: UIButton) {
        self.takeSnapButton.isHidden = true
        self.takeSnapAnimationView.isHidden = false
        self.backButtonView.isHidden = true
        
        startTakeSnapAnimation()
    }
    
    @IBAction func startRecordingDidTap(_ sender: UIButton) {
        self.startRecordingButton.isHidden = true
        self.startRecordingAnimationView.isHidden = false
        self.backButtonView.isHidden = true
        
        self.isReadyForRecording = true
    }
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        resetUI()
    }
    
    func startTakeSnapAnimation() {
        runCode(at: Date(timeIntervalSinceNow:0)) {
            let formattedString = NSMutableAttributedString()
            formattedString
                .normal("3  ", size: 40, color: UIColor.primaryDarkColor)
                .light("2  ", size: 40, color: UIColor.primaryDarkColor.withAlphaComponent(0.5))
                .light("1 ", size: 40, color: UIColor.primaryDarkColor.withAlphaComponent(0.5))
            self.takeSnapAnimationLabel.attributedText = formattedString
            
            self.takeSnapAnimationImageView.image = self.takeSnapAnimationImageView.image!.withRenderingMode(.alwaysTemplate)
            self.takeSnapAnimationImageView.tintColor = UIColor.primaryDarkColor.withAlphaComponent(0.5)
        }
        
        runCode(in: 1.0) {
            let formattedString = NSMutableAttributedString()
            formattedString
                .light("3  ", size: 40, color: UIColor.primaryDarkColor.withAlphaComponent(0.5))
                .normal("2  ", size: 40, color: UIColor.primaryDarkColor)
                .light("1 ", size: 40, color: UIColor.primaryDarkColor.withAlphaComponent(0.5))
            self.takeSnapAnimationLabel.attributedText = formattedString
            
            self.takeSnapAnimationImageView.image = self.takeSnapAnimationImageView.image!.withRenderingMode(.alwaysTemplate)
            self.takeSnapAnimationImageView.tintColor = UIColor.primaryDarkColor.withAlphaComponent(0.5)
        }
        
        runCode(in: 2.0) {
            let formattedString = NSMutableAttributedString()
            formattedString
                .light("3  ", size: 40, color: UIColor.primaryDarkColor.withAlphaComponent(0.5))
                .light("2  ", size: 40, color: UIColor.primaryDarkColor.withAlphaComponent(0.5))
                .normal("1 ", size: 40, color: UIColor.primaryDarkColor)
            self.takeSnapAnimationLabel.attributedText = formattedString
            
            self.takeSnapAnimationImageView.image = self.takeSnapAnimationImageView.image!.withRenderingMode(.alwaysTemplate)
            self.takeSnapAnimationImageView.tintColor = UIColor.primaryDarkColor.withAlphaComponent(0.5)
        }
        
        runCode(in: 3.0) {
            let formattedString = NSMutableAttributedString()
            formattedString
                .light("3  ", size: 40, color: UIColor.primaryDarkColor.withAlphaComponent(0.5))
                .light("2  ", size: 40, color: UIColor.primaryDarkColor.withAlphaComponent(0.5))
                .light("1 ", size: 40, color: UIColor.primaryDarkColor.withAlphaComponent(0.5))
            self.takeSnapAnimationLabel.attributedText = formattedString
            
            self.takeSnapAnimationImageView.image = self.takeSnapAnimationImageView.image!.withRenderingMode(.alwaysTemplate)
            self.takeSnapAnimationImageView.tintColor = UIColor.primaryDarkColor.withAlphaComponent(1.0)
        }
        
        runCode(in: 4.0) {
            //Take Snap
            if let videoConnection = self.cameraManager.stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
                videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
                self.cameraManager.stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                    var imageToBeReturned: UIImage?
                    
                    if (sampleBuffer != nil) {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        
                        UIView.animate(withDuration: 0.1, delay: 0, options: .autoreverse, animations: {
                            self.view.bringSubview(toFront: self.flashView)
                            self.flashView.alpha = 1.0
                        }, completion: { (completed) in
                            self.view.sendSubview(toBack: self.flashView)
                            self.flashView.alpha = 0.0
                            
                            //Write the image to the context to correct the orientation
                            if let originalImage = UIImage(data: imageData!) {
                                //Have the Height to 3:4
                                let newHeight = originalImage.width/3*4 * originalImage.scale
                                let newWidth = originalImage.width * originalImage.scale
                                let newSize = CGSize(width: newWidth, height: newHeight)
                                
                                UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
                                if let _ = UIGraphicsGetCurrentContext() {
                                    originalImage.draw(in: CGRect(x: 0, y: (newHeight - originalImage.height) / 2, width: originalImage.size.width, height: originalImage.size.height))
                                    imageToBeReturned = UIGraphicsGetImageFromCurrentImageContext()
                                    UIGraphicsEndImageContext()
                                    
                                    //Take the Mirror image
                                    imageToBeReturned = imageToBeReturned?.withHorizontallyFlippedOrientation()
                                }
                            }
                             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
                            self.performSegue(withIdentifier: "snapToSnapValidate", sender: imageToBeReturned)
                            self.resetUI()
                        })
                    } else {
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
                        self.performSegue(withIdentifier: "snapToSnapValidate", sender: imageToBeReturned)
                        self.resetUI()
                    }
                })
            }
        }
    }
    
    func runCode(in timeInterval:TimeInterval, _ code:@escaping ()->(Void))
    {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + timeInterval,
            execute: code)
    }
    
    func runCode(at date:Date, _ code:@escaping ()->(Void))
    {
        let timeInterval = date.timeIntervalSinceNow
        runCode(in: timeInterval, code)
    }
    
    
    var selectedFrameNumbers: [Int] = []
    
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        premodelView.isHidden = true
        let string = String(describing: UserDefaults.standard.value(forKey: "UserName")!)
        if string == "Arcadio_f" {
            
            premodelImageView.image = premodelImageView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            premodelImageView.tintColor = UIColor.primaryLightColor
            
            premodelView.backgroundColor = UIColor.primaryDarkColor
            // premodelView.isHidden = falsea
            
            let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(myTapAction))
            mytapGestureRecognizer.numberOfTapsRequired = 1
            self.premodelView.addGestureRecognizer(mytapGestureRecognizer)
            
        }
        
        backButtonView.backgroundColor = UIColor.clear
        backButtonView.shadowColor = UIColor.darkGray
        backButtonView.shadowOffset = CGSize(width: 4, height: 4)
        backButtonView.shadowOpacity = 0.5
        backButtonView.shadowRadius = 6.0
        
        backButton.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        backButton.clipsToBounds = true
        backButton.masksToBounds = true
        
        faceSizeView.setImageInputs([
            ImageSource(image: UIImage(named: "HeadSize")!)
            ])
        faceSizeView.pageControlPosition = .hidden
        faceSizeView.setCurrentPage(0, animated: false)
        
        //Configure Camera Manager
        cameraManager.cameraManagerDelegate = self
        cameraManager.checkCameraAccess()
        
        //Reset Trim using face variables
        self.frameNumberOfMinFaceX = 0
        self.frameNumberOfMaxFaceX = 0
        self.frameNumberOfCurrentFrame = 0
        self.minFaceX = nil
        self.maxFaceX = nil
        
        //Configure UI
        configureUI()
        resetUI()
        
        premodelView.isHidden = true
        //        if string == "Arcadio_f" {
        //
        //            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        //
        //            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        //            loadingIndicator.hidesWhenStopped = true
        //            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        //            loadingIndicator.startAnimating();
        //
        //            alert.view.addSubview(loadingIndicator)
        //            present(alert, animated: true, completion: nil)
        //
        //        CollectionHelper().getCollectionDistributor { (collectionDistributors, error) in
        //            self.activityIndicator?.stopAnimating()
        //
        //            if error == nil {
        //                //Set for Collection Banner
        //
        //                for collection in collectionDistributors {
        //                    CollectionHelper().getCollectionDistributorFrame(forCollectionId: collection.id, completionHandler: { [i = 1] (inventoryFrames, error) in
        //
        //                       // self.premodelView.isHidden = false
        //
        //                       self.dismiss(animated: false, completion: nil)
        //
        //                        self.inventoryArray = inventoryFrames
        //
        //                    })
        //                }
        //
        //            } else {
        //                //TODO: Handle error
        //                print("Error in loading page")
        //            }
        //
        //
        //        }
        //        }
        
    }
    
    func myTapAction(recognizer: UITapGestureRecognizer) {
        
        if inventoryArray.count != 0{
            
            
            let viewVc = self.storyboard?.instantiateViewController(withIdentifier: "ModelChooseController") as! ModelChooseController
            viewVc.frame = inventoryArray[0]
            
            self.navigationController?.pushViewController(viewVc, animated: true)
            
            
        }
        
    }
    
    
    func configureUI() {
        self.snapButtonLabel.textColor = UIColor.primaryLightColor
        self.shootButtonLabel.textColor = UIColor.primaryDarkColor
        
        self.snapShootButtonsHolderView.backgroundColor = UIColor.clear
        self.snapButtonHolderView.backgroundColor = UIColor.primaryDarkColor
        self.shootButtonHolderView.backgroundColor = UIColor.primaryLightColor
        self.shootButtonHolderView.borderWidth = 1.0
        self.shootButtonHolderView.borderColor = UIColor.primaryDarkColor
        
        self.takeSnapAnimationView.backgroundColor = UIColor.primaryLightColor
        self.startRecordingAnimationView.backgroundColor = UIColor.primaryDarkColor
        
        self.takeSnapButton.backgroundColor = UIColor.primaryLightColor
        self.takeSnapButton.setTitleColor(UIColor.primaryDarkColor, for: .normal)
        self.takeSnapButton.setTitleColor(UIColor.white, for: .highlighted)
        self.takeSnapButton.borderWidth = 1.0
        self.takeSnapButton.borderColor = UIColor.primaryDarkColor
        
        self.startRecordingButton.backgroundColor = UIColor.primaryDarkColor
        self.startRecordingButton.setTitleColor(UIColor.primaryLightColor, for: .normal)
        self.startRecordingButton.setTitleColor(UIColor.white, for: .highlighted)
    }
    
    func resetUI() {
        self.backButtonView.isHidden = true
        self.snapShootButtonsHolderView.isHidden = false
        self.snapButtonHolderView.isHidden = false
        self.shootButtonHolderView.isHidden = false
        self.takeSnapButton.isHidden = true
        self.takeSnapAnimationView.isHidden = true
        self.startRecordingButton.isHidden = true
        self.startRecordingAnimationView.isHidden = true
        self.faceSizeView.isHidden = true
        
        self.isReadyForRecording = false
        self.canStartRecording = false
        self.isRecordingStarted = false
        
        self.startRecordingAnimationLabel.textColor = UIColor.white
        self.startRecordingAnimationView.backgroundColor = UIColor.red
        self.startRecordingAnimationLabel.text = "Align your face."
        
        //Configure Metadata UI
        DispatchQueue.main.async {
            self.updateMetadataUI(false, faceAppearance: .noFace)
            
            for view in self.maskAnimationView.subviews {
                view.removeFromSuperview()
            }
        }
        
        //Configure Preview layer
        self.cameraManager.session.sessionPreset = AVCaptureSessionPresetPhoto
        if self.cameraManager.previewLayer.superlayer != nil {
            self.cameraManager.previewLayer.removeFromSuperlayer()
        }
        let previewLayer = self.cameraManager.previewLayer
        previewLayer?.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer!)
        self.view.bringSubview(toFront: self.holderView)
        
        self.view.bringSubview(toFront: self.snapShootButtonsHolderView)
        self.view.bringSubview(toFront: self.backButtonView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let controller = self.tabBarController as? MainTabBarController {
            controller.removeLogoFromWindow()
        }
        
        cameraManager.startRunning()
        
        self.idValues.removeAll()
        
        self.yprValues.removeAll()
        
        self.imageArray.removeAll()
        
        self.valuesDict.removeAll()
        
        self.userImages.removeAll()
        
        self.finalImageArray.removeAll()
        
        self.classDict.removeAll()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        cameraManager.stopRunning()
        
        if let controller = self.tabBarController as? MainTabBarController {
            controller.addLogoAtTheTop()
        }
    }
    
    func cameraAccessDenied() {
        self.showSomethingWentWrongScreen(withMessage: self.cameraAccessDeniedText)
        self.currentErrorType = ErrorType.cameraAccessDenied
    }
    
    func cameraInitializeFailed() {
        self.showSomethingWentWrongScreen(withMessage: self.cameraInitializeErrorText)
        self.currentErrorType = ErrorType.cameraInitializeDenied
    }
    
    func cameraAccessGranted() {
        //Do Nothing
    }
    
    fileprivate func processSomethingWentWrongError() {
        switch (self.currentErrorType!) {
        case .cameraAccessDenied:
            cameraManager = CameraManager()
            cameraManager.cameraManagerDelegate = self
            cameraManager.checkCameraAccess()
            
        case .cameraInitializeDenied:
            cameraManager = CameraManager()
            cameraManager.cameraManagerDelegate = self
            cameraManager.checkCameraAccess()
            
        case .videoRecordingFailed:
            resetUI()
            
        case .videoProcessFailed:
            resetUI()
        }
    }
    
    func closeDidTap() {
        processSomethingWentWrongError()
    }
    
    func tryAgainDidTap() {
        
        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.shared.open(settingsUrl)
       // processSomethingWentWrongError()
    }
    
    
    func getAllFrames(forFrameNumbers frameNumbers: [Int], fromVideoUrl videoUrl: NSURL, appVideoFPS: Int, completionHandler: @escaping (_ error: NSError?) -> Void) {
        //Get all the frames
        //var images: [UIImage] = []
        
        self.activityIndicator?.startAnimating()
        
        userImages.removeAll()
        for frameNumber in frameNumbers {
            let time = CMTimeMake(Int64(frameNumber), Int32(appVideoFPS))
            
            if let img = ImageHelper().image(fromVideoUrl: videoUrl as URL, atTime: time) {
                log.info("Getting user frame for user-\(frameNumber) to find YPR")
                //   images.append(img)
                
                userImages.append(img)
            } else {
                log.warning("UserImage couldn't be extracted for identifier: user\(frameNumber)")
            }
        }
        userImages.remove(at: 12)
        
        self.getFaceDetection(forFrameNumbers: frameNumbers, images: userImages, completionHandler: { (faceDetectionError) in
            completionHandler(faceDetectionError)
        })
    }
    
    
    
    func getFaceDetection(forFrameNumbers frames: [Int], images imgs: [UIImage], completionHandler: @escaping (_ error: NSError?) -> Void) {
        
        var error: NSError?
      
        var valuesArray : [String] = []
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for i in 0..<12{
                
                let imageData1 = UIImageJPEGRepresentation(self.userImages[i] , 0.5)!
                multipartFormData.append(imageData1, withName: "images", fileName: "image.jpg", mimeType: "image/jpeg")
               
                
            }
            
        },
                         to: "https://widget.oichub.com/v3/widget/uploadVideo",method:HTTPMethod.post,
                         headers:nil, encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload
                                    .validate()
                                    .responseJSON { response in
                                        switch response.result {
                                        case .success(let value):
                                            
                                            let dic :NSDictionary = response.result.value! as! NSDictionary
                                            let twDataArray = (dic.value(forKey:"data") as? NSArray) as Array?
                                            
                                            self.idValues.removeAll()
                                            self.yprValues.removeAll()
                                            
                                            for value in twDataArray!{
                                                
                                                let valueDict :NSDictionary = value as! NSDictionary
                                                
                                                valuesArray.append(valueDict.value(forKey: "id") as! String)
                                                
                                                self.idValues.append(valueDict.value(forKey: "id") as! String)
                                                self.yprValues.append(valueDict.value(forKey: "YPR") as! String)
                                            }
                                            
                                            let frames = self.realm.objects(InventoryFrame.self).filter { $0.isTryonCreated == true }
                                            self.frame = frames.first
                                            //                                            let lookzId  = self.frame?.lookzId as! String
                                            //
                                            //                                            self.lastApi(lookzId: lookzId,ids:self.idValues as NSArray)
                                            self.resetUI()
                                             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
                                            
                                            self.performSegue(withIdentifier: "shootToDetailModel", sender: self.frame)
                                            
                                            
                                            
                                        case .failure(let responseError):
                                            print("responseError: \(responseError)")
                                        }
                                }
                            case .failure(let encodingError):
                                print("encodingError: \(encodingError)")
                                
                                error = encodingError as NSError
                            }
                            
                            completionHandler(error)
                            
        })
        
        
    }
    
    // video support Api by jaya
    
//    func lastApi(lookzId : String ,ids: NSArray){
//
//
//        let params: Parameters = [
//            "_id": ids,
//            "frameId": [lookzId]
//
//        ]
//
//        Alamofire.request("https://widget.oichub.com/v3/widget//getGlassFramesVideo", method: .post, parameters: params, encoding: URLEncoding.httpBody)
//            .responseJSON(completionHandler:{ response in
//
//                switch response.result {
//                case .success:
//                    let dic :NSDictionary = response.result.value! as! NSDictionary
//
//                    let twDataArray = (dic.value(forKey:"data") as? NSArray) as Array?
//
//                    //  for basicYpr in self.yprValues{
//
//                    for value in twDataArray!{
//                        self.valuesDict.append(value as! NSDictionary)
//
//
//                    }
//
//                    self.activityIndicator?.stopAnimating()
//                    self.loadingImage(ids: self.idValues)
//                    break
//
//
//
//                case .failure(let error):
//                    print(error)
//
//
//                }
//
//
//            })
//    }
//
//
//    func loadingImage(ids : [String]){
//
//
//        for id in ids {
//
//            for  i  in  0...11{
//
//                if  valuesDict[i].object(forKey: "_id") as! String == id {
//
//
//                    classDict.append(valuesDict[i])
//
//                }else{
//
//                    print("wroung")
//                }
//
//                print(classDict.count)
//
//            }
//
//        }
//
//        finalImageArray.removeAll()
//
//        for dict in classDict{
//
//            let url = URL.init(string:dict.object(forKey: "frameUrl")  as! String)
//
//            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
//                guard let data = data, error == nil else { return }
//
//
//                //  ImageCache.default.store(UIImage.init(data: data)!, forKey: dict.object(forKey: "frameUrl")  as! String)
//                DispatchQueue.main.async() {
//
//                    self.finalImageArray.append(UIImage.init(data: data)!)
//
//                    if self.finalImageArray.count == self.imagesCount{
//
//                        self.finalMethods(imgs: self.tempImage)
//
//                        self.resetUI()
//                        self.performSegue(withIdentifier: "shootToDetailModel", sender: self.frame)
//
//                    }
//
//                }
//
//
//            }
//
//            task.resume()
//
//        }
//    }
//
//
//    func finalMethods(imgs: [UIImage]){
//
//        var a = 0
//
//        //        for i in 0...imagesCount - 1{
//        //            let dict = classDict[i]
//        //
//        //            ImageCache.default.retrieveImage(forKey: dict.object(forKey: "frameUrl") as! String, options: nil) {
//        //                image, cacheType in
//        //                if let image = image {
//        //
//        //                    print( dict.object(forKey: "frameUrl") as! String , "jay insert cache")
//        //
//        //                    self.finalImageArray.append(image)
//        //
//        //
//        //                } else {
//        //                    print("Not exist in cache.")
//        //                }
//        //            }
//        //
//        //
//        //        }
//
//        imageArray.removeAll()
//
//
//        for valueImages  in  classDict{
//
//            let ima = userImages[a]
//
//            let image2 = ima.image(byDrawingImage: finalImageArray[a], inRect: CGRect.init(x: valueImages.value(forKey: "left") as! Int, y: valueImages.value(forKey: "top") as! Int, width: valueImages.value(forKey: "width") as! Int, height: valueImages.value(forKey: "height") as! Int))
//
//
//
//            let paramHeight = valueImages.object(forKey: "height")  as! Int
//            let paramWidth = valueImages.object(forKey: "width")  as! Int
//            let paramTop = valueImages.object(forKey: "top")  as! Int
//            let paramLeft = valueImages.object(forKey: "left")  as! Int
//            print(paramHeight , paramWidth , paramTop , paramLeft ,"[Vasan] Video Capture Merging Image")
//
//            imageArray.append(image2!)
//
//            a = a + 1
//        }
//
//        for dict in classDict{
//
//            ImageCache.default.removeImage(forKey:dict.object(forKey: "frameUrl") as! String)
//
//        }
//
//    }
    
    
}


// MARK: - Face Detection
extension VideoCaptureViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var faces = [CGRect]()
        
        if isRecordingStarted {
            frameNumberOfCurrentFrame = frameNumberOfCurrentFrame + 1
        }
        
        for metadataObject in metadataObjects as! [AVMetadataObject] {
            if metadataObject.type == AVMetadataObjectTypeFace {
                let transformedMetadataObject = cameraManager.previewLayer?.transformedMetadataObject(for: metadataObject)
                let face = transformedMetadataObject?.bounds
                faces.append(face!)
            }
        }
        
        if faces.count > 0 {
            //Find MaxFace
            var maxFace = faces[0]
            for face in faces {
                if (face.size.width >= maxFace.size.width) || (face.size.height >= maxFace.size.height) {
                    maxFace = face
                }
            }
            
            DispatchQueue.main.async {
                let isValid = self.isValidFace(self.faceFrameView.frame, maxFace)
                self.updateMetadataUI(isValid, faceAppearance: self.faceAppearance!)
            }
            
            //Calculate the Maximum and Minimum face X, for trimming
            if isRecordingStarted {
                let currentFaceX = maxFace.minX
                
                if minFaceX == nil {
                    minFaceX = currentFaceX
                }
                if maxFaceX == nil {
                    maxFaceX = currentFaceX
                }
                
                if currentFaceX < minFaceX! {
                    minFaceX = currentFaceX
                    frameNumberOfMinFaceX = frameNumberOfCurrentFrame
                }
                
                if currentFaceX >= maxFaceX! {
                    maxFaceX = currentFaceX
                    frameNumberOfMaxFaceX = frameNumberOfCurrentFrame
                }
            }
        } else {
            DispatchQueue.main.async {
                self.updateMetadataUI(false, faceAppearance: .noFace)
            }
        }
    }
    
    func isValidFace(_ frame :CGRect,_ face :CGRect ) -> Bool {
        var isValid = false
        if face.size.height > 450 && face.size.width > 450 {
            faceAppearance = .big
            
        } else if face.origin.x < frame.origin.x {
            faceAppearance = .left
            
        } else if face.origin.y < frame.origin.y {
            faceAppearance = .top
            
        } else if face.origin.x + face.size.width > frame.origin.x + frame.size.width {
            faceAppearance = .right
            
        } else if face.origin.y + face.size.height > frame.origin.y + frame.size.height {
            faceAppearance = .bottom
            
        } else if face.size.height < 250 && face.size.width < 250 {
            faceAppearance = .small
            
        } else {
            faceAppearance = .perfect
            isValid = true
        }
        
        return isValid
    }
    
    func updateMetadataUI(_ isValid: Bool, faceAppearance: FaceAppearance) {
        if isReadyForRecording == true && canStartRecording == false {
            if isValid {
                self.startRecordingAnimationLabel.textColor = UIColor.primaryLightColor
                self.startRecordingAnimationView.backgroundColor = UIColor.primaryDarkColor
                self.startRecordingAnimationLabel.text = "Perfect!"
                self.canStartRecording = true
                runCode(in: 1.5) {
                    self.startRecording()
                }
            } else {
                self.startRecordingAnimationLabel.textColor = UIColor.white
                self.startRecordingAnimationView.backgroundColor = UIColor.red
                
                switch faceAppearance {
                case .big:
                    self.startRecordingAnimationLabel.text = "You are too close."
                    faceSizeView.setImageInputs([
                        ImageSource(image: UIImage(named: "tooClose")!)
                        ])
                case .small:
                    faceSizeView.setImageInputs([
                        ImageSource(image: UIImage(named: "HeadSize")!)
                        ])
                    self.startRecordingAnimationLabel.text = "You are too far."
                case .left, .right, .top, .bottom, .noFace:
                    faceSizeView.setImageInputs([
                        ImageSource(image: UIImage(named: "HeadSize")!)
                        ])
                    self.startRecordingAnimationLabel.text = "Align your face."
                default:
                    faceSizeView.setImageInputs([
                        ImageSource(image: UIImage(named: "HeadSize")!)
                        ])
                    self.startRecordingAnimationLabel.text = "Align your face."
                }
            }
        }
    }
}


// MARK: - Video Record and process functions
extension VideoCaptureViewController: AVCaptureFileOutputRecordingDelegate, SRCountdownTimerDelegate {
    
    func startRecording() {
        //Display Gif
        maskAnimationView.isHidden = false
        let gifmanager = SwiftyGifManager(memoryLimit:20)
        let gif = UIImage(gifName: "Head_v1.gif")
        let imageView = UIImageView(gifImage: gif, manager: gifmanager, loopCount: 1)
        imageView.frame = CGRect(x: 0, y: 0, width: maskAnimationView.frame.width, height: maskAnimationView.frame.height)
        maskAnimationView.addSubview(imageView)
        self.faceSizeView.isHidden = true
        //self.hideView(faceSizeView, inDuration: 1.0)
        
        //Start Recording
        isRecordingStarted = true
        self.cameraManager.movieOutput.startRecording(toOutputFileURL: videoOutputFilePath as URL!, recordingDelegate: self)
        
        //Run instructions
        runCode(at: Date(timeIntervalSinceNow:0)) {
            self.startRecordingAnimationLabel.text = "Turn your face to Right."
        }
        
        runCode(in: 2.5) {
            self.startRecordingAnimationLabel.text = "Turn your face to Left."
        }
        
        runCode(in: 7.5) {
            self.startRecordingAnimationLabel.text = "And back to the center"
        }
        
        runCode(in: 10.0) {
            self.maskAnimationView.isHidden = true
            self.snapShootButtonsHolderView.isHidden = true
            self.activityIndicator?.startAnimating()
            
            self.stopRecording()
        }
    }
    
    func stopRecording() {
        self.cameraManager.movieOutput.stopRecording()
        cameraManager.stopRunning()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if (error != nil) {
            log.error("Unable to save video:\(error.localizedDescription)")
            self.currentErrorType = ErrorType.videoRecordingFailed
            self.showSomethingWentWrongScreen(withMessage: (error?.localizedDescription)!)
            
        } else {
            log.info("MinFaceX : \(minFaceX ?? -1.0)")
            log.info("MaxFaceX : \(maxFaceX ?? -1.0)")
            log.info("FrameNumberOfMinFaceX : \(frameNumberOfMinFaceX)")
            log.info("FrameNumberOfMaxFaceX : \(frameNumberOfMaxFaceX)")
            
            log.info("OutputFile URL: \(outputFileURL)")
            let data = NSData(contentsOf: self.videoOutputFilePath as URL)!
            log.info("Original File size: \(Double(Double(data.length) / 1048576.0)) MB")
            
            //Crop Video
            let uniqueString = NSUUID().uuidString
            let tempUrlString = NSTemporaryDirectory() + uniqueString
            let croppedUrl = NSURL.fileURL(withPath: tempUrlString + "-cropped.mov")
            
            let appLocalVideoUrl = NSURL(fileURLWithPath: (FileHelper().getDocumentDirectoryPath() as NSString).appendingPathComponent(uniqueString + "-local.mov")) as URL
            
            cropVideo(inputUrl: self.videoOutputFilePath as URL, outputUrl: croppedUrl, completion: { (outputUrl) -> () in
                let data = NSData(contentsOf: croppedUrl)!
                log.info("FileSize after cropping: \(Double(Double(data.length) / 1048576.0)) MB")
                
                //Compress Video
                let compressedUrl = NSURL.fileURL(withPath: NSTemporaryDirectory() + uniqueString + "-compressed.mp4")
                self.processVideo(inputUrl: croppedUrl, outputUrl: compressedUrl, videoSize: self.model.serverVideoSize, videoFrameRate: Float(self.model.appVideoFrameRate), videoBitRate: self.model.serverVideoBitRate, completion: { (outputUrl) in
                    let data = NSData(contentsOf: compressedUrl as URL)!
                    log.info("FileSize after processing: \(Double(Double(data.length) / 1048576.0)) MB")
                    // changes by jaya
                    //                    HPEHelper().extractFramesFromVideo(internalUserName: uniqueString, videoUrl: compressedUrl as NSURL, videoFPS: self.model.appVideoFrameRate, completionHandler: { (newUser, error) in
                    //                        if (error != nil) {
                    //                            self.currentErrorType = ErrorType.videoProcessFailed
                    //                            self.showSomethingWentWrongScreen(withMessage: (error?.localizedDescription)!)
                    //                        }
                    //                        else {
                    //                            if let _ = self.tabBarController as! MainTabBarController? {
                    //                                self.activityIndicator?.stopAnimating()
                    //
                    //                                self.tryon3D.user = newUser
                    //                                self.performSegue(withIdentifier: "shootToDetailModel", sender: nil)
                    //
                    //                                //Configure back to default
                    //                                self.resetUI()
                    //                            }
                    //                        }
                    //                    })
                    
                    
                    let numberOfFrames: Int = ImageHelper().numberOfFrames(inVideoUrl: (compressedUrl as NSURL) as URL )
                    let frameFrequency: Double = Double(numberOfFrames) / Double(15)
                    let frameFrequencyRounded: Double = (frameFrequency * 10).rounded() / 10
                    
                    
                    var i: Double = 1.0
                    while Int(i) <= numberOfFrames {
                        self.selectedFrameNumbers.append(Int(i))
                        
                        i = i + frameFrequencyRounded
                    }
                    
                    self.getAllFrames(forFrameNumbers: self.selectedFrameNumbers, fromVideoUrl: compressedUrl as NSURL, appVideoFPS: self.model.appVideoFrameRate, completionHandler: { (error) in
                        
                        if error == nil  {
                        }else {
                            //completionHandler(nil, error)
                        }
                    })
                    
                    //TODO: Is this required?
                    //Upload Video
                    //AWSUploadHelper().uploadVideo(fileURL: compressedUrl as NSURL, bucketName: self.s3BucketNameForVideoUpload, fileS3UploadKeyName: s3UploadKeyName, completionHandler: self.completionHandler, progressBlock: self.progressBlock)
                    
                    //Process the same video in different resolution
                    self.processVideoForApp(inputUrl: croppedUrl, outputUrl: appLocalVideoUrl, completion: { (outputUrl) in
                        if outputUrl == nil {
                            log.error("Process Video for App - Failed")
                        } else {
                            let data = NSData(contentsOf: outputUrl!)!
                            log.info("FileSize of App Video: \(Double(Double(data.length) / 1048576.0)) MB")
                        }
                    })
                })
            })
            
            //Remove in Main async
            DispatchQueue.main.async {
                self.cameraManager.previewLayer.removeFromSuperlayer()
            }
        }
    }
    
    func cropVideo(inputUrl: URL, outputUrl: URL, completion: @escaping (_ outputUrl : URL?) -> ()) {
        let avAsset = AVURLAsset(url: inputUrl, options: nil)
        let videoAsset: AVAsset = AVAsset(url: inputUrl)
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo ).first! as AVAssetTrack
        let videoComposition = AVMutableVideoComposition()
        
        videoComposition.renderSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
        videoComposition.frameDuration = CMTimeMake(1, Int32(model.appVideoFrameRate))
        
        log.info("FrameRate before crop: \(clipVideoTrack.nominalFrameRate)")
        log.info("Bitrate before crop: \(clipVideoTrack.estimatedDataRate)")
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(500, 25))
        
        //Rotate the video
        let transform1 = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: 0)
        let transform2 = transform1.rotated(by: .pi/2)
        let finalTransform = transform2
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        // Export
        let encoder = SDAVAssetExportSession(asset: avAsset)
        encoder?.outputFileType = AVFileTypeQuickTimeMovie
        encoder?.outputURL = outputUrl as URL!
        encoder?.videoComposition = videoComposition
        
        if model.trimVideoBasedOnFaceX {
            if frameNumberOfMaxFaceX - frameNumberOfMinFaceX > 25 {
                //Trim the video based on Min and Max FaceX
                let startTime = CMTime(seconds: Double(frameNumberOfMinFaceX)/Double(clipVideoTrack.nominalFrameRate), preferredTimescale: 1000)
                let endTime = CMTime(seconds: Double(frameNumberOfMaxFaceX)/Double(clipVideoTrack.nominalFrameRate), preferredTimescale: 1000)
                
                encoder?.timeRange = CMTimeRange(start: startTime, end: endTime)
            } else {
                log.warning("Skipping Trim Video, as min and max frame number are \(frameNumberOfMinFaceX) and \(frameNumberOfMaxFaceX)")
            }
        }
        
        //Reset Trim using face variables
        self.frameNumberOfMinFaceX = 0
        self.frameNumberOfMaxFaceX = 0
        self.frameNumberOfCurrentFrame = 0
        self.minFaceX = nil
        self.maxFaceX = nil
        
        encoder?.videoSettings =
            [
                AVVideoCodecKey : AVVideoCodecH264,
                AVVideoWidthKey : clipVideoTrack.naturalSize.height,
                AVVideoHeightKey : clipVideoTrack.naturalSize.width,
                AVVideoCompressionPropertiesKey :
                    [
                        AVVideoAverageBitRateKey: clipVideoTrack.estimatedDataRate,
                        AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel,
                        AVVideoAverageNonDroppableFrameRateKey : clipVideoTrack.nominalFrameRate
                ]
        ]
        
        encoder?.exportAsynchronously(completionHandler: {
            let status = encoder?.status
            if status == .completed {
                let videoAsset: AVAsset = AVAsset(url: outputUrl as URL)
                let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo ).first! as AVAssetTrack
                log.info("FrameRate after cropping: \(clipVideoTrack.nominalFrameRate)")
                log.info("Bitrate after cropping: \(clipVideoTrack.estimatedDataRate)")
                
                completion(outputUrl)
                return
            } else if status == .cancelled {
                log.error("Crop Video - Export failed - \(String(describing: encoder?.error))")
            } else {
                log.error("Crop Video - Export failed - \(String(describing: encoder?.error))")
            }
            
            completion(nil)
            return
        })
    }
    
    func processVideoForApp(inputUrl: URL, outputUrl: URL, completion: @escaping (_ outputUrl : URL?) -> ()) {
        let avAsset = AVURLAsset(url: inputUrl, options: nil)
        let videoAsset: AVAsset = AVAsset(url: inputUrl)
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo ).first! as AVAssetTrack
        let videoComposition = AVMutableVideoComposition()
        
        let newHeight = clipVideoTrack.naturalSize.width/3*4
        videoComposition.renderSize = CGSize(width: clipVideoTrack.naturalSize.width, height: newHeight)
        videoComposition.frameDuration = CMTimeMake(1, Int32(model.appVideoFrameRate))
        
        //Update Display Size, for further calculations
        self.model.displayImageSize = CGSize(width: clipVideoTrack.naturalSize.width, height: newHeight)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(500, 25))
        
        let transform1 = CGAffineTransform(translationX: 0, y: -(clipVideoTrack.naturalSize.height - newHeight)/2)
        let finalTransform = transform1
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        let encoder = SDAVAssetExportSession(asset: avAsset)
        encoder?.outputFileType = AVFileTypeQuickTimeMovie
        encoder?.outputURL = outputUrl as URL!
        encoder?.videoComposition = videoComposition
        encoder?.videoSettings =
            [
                AVVideoCodecKey : AVVideoCodecH264,
                AVVideoWidthKey : clipVideoTrack.naturalSize.width,
                AVVideoHeightKey : newHeight,
                AVVideoCompressionPropertiesKey :
                    [
                        AVVideoAverageBitRateKey: clipVideoTrack.estimatedDataRate,
                        AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel,
                        AVVideoAverageNonDroppableFrameRateKey : clipVideoTrack.nominalFrameRate
                ]
        ]
        
        encoder?.exportAsynchronously(completionHandler: {
            let status = encoder?.status
            if status == .completed {
                let videoAsset: AVAsset = AVAsset(url: outputUrl as URL)
                let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo ).first! as AVAssetTrack
                log.info("FrameRate after processing for App: \(clipVideoTrack.nominalFrameRate)")
                log.info("Bitrate after processing for App: \(clipVideoTrack.estimatedDataRate)")
                
                completion(outputUrl)
                return
            } else if status == .cancelled {
                log.error("Process Video - Export failed - \(String(describing: encoder?.error))")
            } else {
                log.error("Process Video - Export failed - \(String(describing: encoder?.error))")
            }
            
            completion(nil)
            return
        })
    }
    
    func processVideo(inputUrl: URL, outputUrl: URL, videoSize: CGSize?, videoFrameRate: Float?, videoBitRate: Float?, completion: @escaping (_ outputUrl : URL?) -> ()) {
        let avAsset = AVURLAsset(url: inputUrl, options: nil)
        let videoAsset: AVAsset = AVAsset(url: inputUrl)
        let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo ).first! as AVAssetTrack
        
        var videoOutputSize: CGSize?
        if let size = videoSize {
            videoOutputSize = size
        } else {
            videoOutputSize = CGSize(width: clipVideoTrack.naturalSize.width, height: clipVideoTrack.naturalSize.height)
        }
        
        var videoOutputFrameRate: Float?
        if let rate = videoFrameRate {
            videoOutputFrameRate = rate
        } else {
            videoOutputFrameRate = clipVideoTrack.nominalFrameRate
        }
        
        var videoOutputBitRate: Float?
        if let rate = videoBitRate {
            videoOutputBitRate = rate
        } else {
            videoOutputBitRate = clipVideoTrack.estimatedDataRate
        }
        
        let encoder = SDAVAssetExportSession(asset: avAsset)
        encoder?.outputFileType = AVFileTypeMPEG4
        encoder?.outputURL = outputUrl as URL!
        encoder?.videoSettings =
            [
                AVVideoCodecKey : AVVideoCodecH264,
                AVVideoWidthKey : (videoOutputSize?.width)!,
                AVVideoHeightKey : (videoOutputSize?.height)!,
                AVVideoCompressionPropertiesKey :
                    [
                        AVVideoAverageBitRateKey: videoOutputBitRate!,
                        AVVideoProfileLevelKey: AVVideoProfileLevelH264MainAutoLevel,
                        AVVideoAverageNonDroppableFrameRateKey : videoOutputFrameRate!
                ]
        ]
        
        encoder?.exportAsynchronously(completionHandler: {
            let status = encoder?.status
            if status == .completed {
                let videoAsset: AVAsset = AVAsset(url: outputUrl as URL)
                let clipVideoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo ).first! as AVAssetTrack
                log.info("FrameRate after processing: \(clipVideoTrack.nominalFrameRate)")
                log.info("Bitrate after processing: \(clipVideoTrack.estimatedDataRate)")
                
                completion(outputUrl)
                return
            } else if status == .cancelled {
                log.error("Process Video - Export failed - \(String(describing: encoder?.error))")
            } else {
                log.error("Process Video - Export failed - \(String(describing: encoder?.error))")
            }
            completion(nil)
            return
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        
        if let snapValidateController = segue.destination as? SnapValidateController {
            snapValidateController.userImage = sender as? UIImage
        }
        
        if let detailModelController = segue.destination as? DetailModelController {
            
            detailModelController.videoImages = self.imageArray
            
            detailModelController.videoModelDelegate = self
            
            detailModelController.idValues = self.idValues
            
            detailModelController.valuesDicts = self.valuesDict
            
            detailModelController.userImages = self.userImages
            
            if let frame = sender as? InventoryFrame {
                detailModelController.frame = frame
            }
        }
    }
    // not useing jaya
    func videoFrameChange(frame: InventoryFrame , ids: NSArray , valuesDicts : [NSDictionary]){
        
        let lookzId  = frame.lookzId as! String
        self.frame = frame
        
        self.valuesDict = valuesDicts
        
        self.idValues = ids as! [String]
        
       // self.lastApi(lookzId: "lookz_00005245",ids:self.idValues as NSArray)
        
        
    }
    
}

extension UIImage {
    
    func image(byDrawingImage image: UIImage, inRect rect: CGRect) -> UIImage! {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
}
extension UserDefaults {
    func set(image: UIImage?, forKey key: String) {
        guard let image = image else {
            set(nil, forKey: key)
            return
        }
        set(UIImageJPEGRepresentation(image, 1.0), forKey: key)
    }
    func image(forKey key:String) -> UIImage? {
        guard let data = data(forKey: key), let image = UIImage(data: data)
            else  { return nil }
        return image
    }
    func set(imageArray value: [UIImage]?, forKey key: String) {
        guard let value = value else {
            set(nil, forKey: key)
            return
        }
        set(NSKeyedArchiver.archivedData(withRootObject: value), forKey: key)
    }
    func imageArray(forKey key:String) -> [UIImage]? {
        guard  let data = data(forKey: key),
            let imageArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [UIImage]
            else { return nil }
        return imageArray
    }
}

