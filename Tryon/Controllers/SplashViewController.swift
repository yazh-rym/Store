//
//  SplashViewController.swift
//  Tryon
//
//  Created by Udayakumar N on 27/12/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//


//Something went wrong.
//Please check your network connection


import UIKit

class SplashViewController: BaseViewController {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    private var isModelDataLoaded = false
    private var isUserDataLoaded = false
    
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure UI
        if self.model.accessToken != "" {
            self.view.backgroundColor = UIColor.mainBackgroundColor
        } else {
            self.view.backgroundColor = UIColor.primaryLightColor
        }
        
        //Make API calls, if needed
        checkLogin()
    }
    
    private func checkLogin() {
        activityIndicator?.startAnimating()
        
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            
            if self.model.accessToken != "" {
                //Navigate to register data, in order to fetch all required data
                AppDelegate.shared.rootViewController.switchToRegisterData()
                
            } else {
                //Navigate to register
                AppDelegate.shared.rootViewController.switchToRegister()
                
            }
        }
    }
}
