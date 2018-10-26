//
//  AppDelegate.swift
//  Tryon
//
//  Created by Udayakumar on 2/28/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//
import UIKit
import Alamofire
import Fabric
import Crashlytics
import AWSCognito
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let model = TryonModel.sharedInstance
    var window: UIWindow?
    let currencyCode = "INR"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Configure S3
        EndPoints().s3Config()
        
        //Configure Crashlytics
        Fabric.with([Crashlytics.self, AWSCognito.self])
        
        //Configure Swift Beaver
        configureSwiftBeaver()
        
        //Configure UI
        self.window?.tintColor = UIColor.primaryDarkColor
        let attribute = NSDictionary(object: UIFont(name: "SFUIText-Regular", size: 24.0)!, forKey: NSFontAttributeName as NSCopying)
        UISegmentedControl.appearance().setTitleTextAttributes(attribute as? [AnyHashable : Any], for: UIControlState.normal)
        UIApplication.shared.statusBarStyle = .default
        
        //Setup root view controller
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()

        return true
    }
    
    func configureSwiftBeaver() {
        //Configure SwiftyBeaver
        let console = ConsoleDestination()  // log to Xcode Console
        console.format = "$DHH:mm:ss$d - $N->$F: $L: $M"
        log.addDestination(console)
        
        let file = FileDestination()  // log to default swiftybeaver.log file
        file.format = "$DHH:mm:ss$d - $N->$F: $L: $M"
        log.addDestination(file)
        
        let cloud = SBPlatformDestination(appID: "pgx8LV", appSecret: "btrocfWgvliqycaddwl7bhywiqMbieaa", encryptionKey: "nwybisdgMhow0uknkbltmjeymwimjlav") // to cloud
        cloud.format = "$DHH:mm:ss$d - $N->$F: $L: $M"
        log.addDestination(cloud)
        cloud.minLevel = SwiftyBeaver.Level.info
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SettingsHelper.checkAndExecuteSettings()
        SettingsHelper.setVersionAndBuildNumber()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    // MARK: Custom Methods
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func getStringValueFormattedAsCurrency(value: String) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.currencyCode = currencyCode
        numberFormatter.maximumFractionDigits = 2
        
        let formattedValue = numberFormatter.string(from: NumberFormatter().number(from: value)!)
        return formattedValue!
    }
    
    func getDocDir() -> String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
    }
}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var rootViewController: RootViewController {
        return window!.rootViewController as! RootViewController
    }
}
