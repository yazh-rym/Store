//
//  ShowDemoController.swift
//  Tryon
//
//  Created by Udayakumar N on 14/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Material
import Alamofire
import Appsee


class ShowDemoController: UIViewController {
    
    
    // MARK: - Class variables
    
    @IBOutlet weak var demoVideoLayer: UIView!
    @IBOutlet weak var shootButton: RaisedButton!
    @IBOutlet weak var agreementRadioButton: ISRadioButton!
    @IBOutlet weak var volumeButton: UIButton!
    
    
    @IBAction func agreementDidChange(_ sender: ISRadioButton) {
        if sender.isSelected {
            shootButton.isUserInteractionEnabled = true
            shootButton.backgroundColor = UIColor.primaryColor
        } else {
            shootButton.isUserInteractionEnabled = false
            shootButton.backgroundColor = UIColor.mainButtonDisableBackgroundColor
        }
    }
    
    @IBAction func needHelpDidTap(_ sender: UIButton) {
        self.showOnBoardingScreens()
    }
    
    @IBAction func volumeDidTap(_ sender: UIButton) {
        model.volumeIsMute = !model.volumeIsMute
        showVolumeButton()
    }
    
    
    let model = TryonModel.sharedInstance
    var player: AVPlayer!
    var avpController = AVPlayerViewController()
    
    
    // MARK: - Init functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDemoVideo()
        agreementRadioButton.isSelected = true
        
        //TODO: Fix this
        //Check login
//        checkLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.player.seek(to: kCMTimeZero)
        self.player.play()
        
        showVolumeButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if model.showOnBoarding {
            //Appsee - Start session
            Appsee.forceNewSession()
            Appsee.startScreen("ShowDemo")

            self.showOnBoardingScreens()
        } else {
            Appsee.startScreen("ShowDemo")
        }
    }
    
    
    // MARK: - Volume functions
    
    func showVolumeButton() {
        if model.volumeIsMute {
            if let image = UIImage(named: "VolumeImageMute") {
                volumeButton.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: "VolumeImage") {
                volumeButton.setImage(image, for: .normal)
            }
        }
    }
    
    
    // MARK: - OnBoarding functions
    
    func showOnBoardingScreens() {
        let onBoardingVC: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnBoarding")
        self.present(onBoardingVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Setup Video functions
    
    func setupDemoVideo() {
        let moviePath = Bundle.main.path(forResource: "demoVideo_v2", ofType: "mp4")
        if let path = moviePath {
            let url = NSURL.fileURL(withPath: path)
            let item = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: item)
            self.player.play()
            self.avpController = AVPlayerViewController()
            self.avpController.player = self.player
            self.avpController.showsPlaybackControls = false
            self.avpController.view.backgroundColor = UIColor.white
            avpController.view.frame = demoVideoLayer.frame
            self.addChildViewController(avpController)
            avpController.view.isUserInteractionEnabled = false
            self.view.addSubview(avpController.view)
            
            self.loopDemoVideo(demoVideoPlayer: self.player)
        }
    }
    
    func loopDemoVideo(demoVideoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            demoVideoPlayer.seek(to: kCMTimeZero)
            demoVideoPlayer.play()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "videoShoot" || segue.identifier == "selectModel" {
            if model.customerReport == nil {
                model.sessionStartTime = Date()
            }
        } else if segue.identifier == "termsOfUse" {
            let webController = segue.destination as! CustomWebController
            webController.urlString = EndPoints().termsOfUseUrlString
            webController.screenName = "TermsOfUse"
        } else if segue.identifier == "privacyPolicy" {
            let webController = segue.destination as! CustomWebController
            webController.urlString = EndPoints().privacyPolicyUrlString
            webController.screenName = "PrivacyPolicy"
        }
    }
    
    
    //MARK: Register and Validate
    func checkLogin() {
        // Check Login
        if model.isLogin == false {
            showRegisterScreen()
        } else {
            validateDevice()
        }
    }
    
    func showRegisterScreen() {
        let frontVC: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "register")
        self.present(frontVC, animated: true, completion: nil)        
    }
    
    func showRegisterScreen(withMessage message: String) {
        showRegisterScreen()
        self.showAlertMessage(withTitle: "Error", message: message)
    }
    
    func validateDevice() {
        
        let deviceVerifyParams: Parameters = ["validate" : model.deviceId]
        
        Alamofire.request(EndPoints().deviceAuthenticationUrl, method: .get, parameters: deviceVerifyParams)
            .responseJSON { response in
                if response.result.isSuccess {
                    let responseDict = response.result.value as! NSDictionary
                    
                    if responseDict.value(forKey: "status") as! String == "success" || responseDict.value(forKey: "status") as! String == "OK" {
                        let processValue = responseDict.value(forKey: "process") as! Int
                        if processValue == 1 {
                            self.model.isLogin = true
                            
                            //TODO: Is this required?
                            self.model.deviceId = self.model.deviceId
                            
                            log.info("Validation Passed for device ID - \(self.model.deviceId)")
                        } else if processValue == 2 || processValue == 0 {
                            self.model.isLogin = false
                            self.validateDeviceDidFail(withResponse: responseDict)
                            log.error("Validation Failed with process value: \(processValue)")
                        }
                    }
                    else {
                        if let message = responseDict.value(forKey: "message") as! String? {
                            //TODO: Show something failed screen
                            log.error("Validation API Failed with message: \(message)")
                            
                        } else {
                            log.error("Validation API call Failed with response: \(response)")
                        }
                        self.model.isLogin = false
                        self.validateDeviceDidFail(withResponse: responseDict)
                    }
                } else {
                    //TODO: Show something failed screen
                    log.error("Validation API call Failed with response: \(response)")
                }
        }
    }
    
    func validateDeviceDidFail(withResponse response: NSDictionary?) {
        if let message = response?.value(forKey: "message") as! String? {
            showRegisterScreen(withMessage: message)
        } else {
            showRegisterScreen()
        }
    }
}
