//
//  SettingsHelper.swift
//  Tryon
//
//  Created by Udayakumar N on 16/10/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import Foundation


class SettingsHelper {
    
    struct SettingsBundleKeys {
        static let analyticsKey = "analytics_preference"
        static let appVersionKey = "version_preference"
        static let buildVersionKey = "build_preference"
    }
    
    class func checkAndExecuteSettings() {
        if UserDefaults.standard.bool(forKey: SettingsBundleKeys.analyticsKey) {
            //Enable Analytics, if any
        } else {
            //Disable Analytics, if any
        }
    }
    
    class func setVersionAndBuildNumber() {
        let userDefaults = UserDefaults.standard
        
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        userDefaults.setValue(version, forKey: "version_preference")
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        userDefaults.setValue(build, forKey: "build_preference")
        
        userDefaults.synchronize()
    }
}
